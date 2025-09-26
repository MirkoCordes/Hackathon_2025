package de.eq3.hackathon.kreisverwaltung.controller;

import de.eq3.hackathon.kreisverwaltung.dto.DataAccessRequestDto;
import de.eq3.hackathon.kreisverwaltung.entity.Certificate;
import de.eq3.hackathon.kreisverwaltung.entity.DataAccessRequest;
import de.eq3.hackathon.kreisverwaltung.entity.Datasource;
import de.eq3.hackathon.kreisverwaltung.entity.User;
import de.eq3.hackathon.kreisverwaltung.repository.DataAccessRequestRepository;
import de.eq3.hackathon.kreisverwaltung.service.CertificateService;
import de.eq3.hackathon.kreisverwaltung.service.DatasourceService;
import de.eq3.hackathon.kreisverwaltung.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/data-access-requests")
@RequiredArgsConstructor
public class DataAccessRequestController {

    private final DataAccessRequestRepository accessRequestRepository;
    private final DatasourceService datasourceService;
    private final CertificateService certificateService;
    private final UserService userService;

    @PostMapping
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<?> requestDataAccess(@RequestBody DataAccessRequestDto requestDto) {
        try {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            User currentUser = userService.findByUsername(auth.getName()).orElse(null);

            if (currentUser == null) {
                return ResponseEntity.status(401).body("User not found");
            }

            // Datasource validieren
            Optional<Datasource> datasourceOpt = datasourceService.getDatasourceById(requestDto.getDatasourceId());
            if (datasourceOpt.isEmpty()) {
                return ResponseEntity.badRequest().body("Datasource not found");
            }

            Datasource datasource = datasourceOpt.get();

            // Certificate validieren
            Optional<Certificate> certificateOpt = certificateService.getCertificateById(requestDto.getCertificateId());
            if (certificateOpt.isEmpty()) {
                return ResponseEntity.badRequest().body("Certificate not found");
            }

            Certificate certificate = certificateOpt.get();

            // Prüfen ob Certificate dem User gehört
            if (!certificate.getUser().equals(currentUser)) {
                return ResponseEntity.status(403).body("Certificate does not belong to user");
            }

            // Prüfen ob Certificate aktiv ist
            if (!certificate.isActive()) {
                return ResponseEntity.badRequest().body("Certificate is not active");
            }

            // Prüfen ob bereits ein Request existiert
            List<DataAccessRequest.Status> activeStatuses = Arrays.asList(
                    DataAccessRequest.Status.PENDING,
                    DataAccessRequest.Status.UNDER_REVIEW,
                    DataAccessRequest.Status.APPROVED);

            if (accessRequestRepository.existsByUserAndDatasourceAndStatusIn(currentUser, datasource, activeStatuses)) {
                return ResponseEntity.badRequest().body("You already have an active request for this datasource");
            }

            // Request erstellen
            DataAccessRequest accessRequest = new DataAccessRequest();
            accessRequest.setUser(currentUser);
            accessRequest.setDatasource(datasource);
            accessRequest.setCertificate(certificate);
            accessRequest.setRequestReason(requestDto.getRequestReason());
            accessRequest.setIntendedUse(requestDto.getIntendedUse());
            accessRequest.setStatus(DataAccessRequest.Status.PENDING);

            DataAccessRequest saved = accessRequestRepository.save(accessRequest);

            return ResponseEntity.ok(Map.of(
                    "message", "Data access request submitted successfully",
                    "requestId", saved.getId(),
                    "status", saved.getStatus()));

        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "error", "Request failed: " + e.getMessage()));
        }
    }

    @GetMapping("/my")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<List<DataAccessRequest>> getMyRequests() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User currentUser = userService.findByUsername(auth.getName()).orElse(null);

        if (currentUser == null) {
            return ResponseEntity.status(401).build();
        }

        List<DataAccessRequest> requests = accessRequestRepository.findByUser(currentUser);
        return ResponseEntity.ok(requests);
    }

    @GetMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<DataAccessRequest> getRequest(@PathVariable Long id) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User currentUser = userService.findByUsername(auth.getName()).orElse(null);

        Optional<DataAccessRequest> requestOpt = accessRequestRepository.findById(id);

        if (requestOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        DataAccessRequest request = requestOpt.get();

        // Nur eigene Requests oder Admin/Reviewer können alle sehen
        if (!request.getUser().equals(currentUser) &&
                currentUser != null &&
                currentUser.getRole() != User.Role.ADMIN &&
                currentUser.getRole() != User.Role.REVIEWER) {
            return ResponseEntity.status(403).build();
        }

        return ResponseEntity.ok(request);
    }

    // === ADMIN/REVIEWER ENDPOINTS ===

    @GetMapping("/pending")
    @PreAuthorize("hasRole('ADMIN') or hasRole('REVIEWER')")
    public ResponseEntity<List<DataAccessRequest>> getPendingRequests() {
        List<DataAccessRequest.Status> pendingStatuses = Arrays.asList(
                DataAccessRequest.Status.PENDING,
                DataAccessRequest.Status.UNDER_REVIEW);
        List<DataAccessRequest> pending = accessRequestRepository.findByStatuses(pendingStatuses);
        return ResponseEntity.ok(pending);
    }

    @GetMapping("/all")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<DataAccessRequest>> getAllRequests() {
        List<DataAccessRequest> all = accessRequestRepository.findAll();
        return ResponseEntity.ok(all);
    }

    @PostMapping("/{id}/review")
    @PreAuthorize("hasRole('ADMIN') or hasRole('REVIEWER')")
    public ResponseEntity<?> reviewRequest(
            @PathVariable Long id,
            @RequestParam DataAccessRequest.Status status,
            @RequestParam(required = false) String reviewNotes,
            @RequestParam(required = false) String accessGrantedUntilStr) {

        try {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            String reviewerUsername = auth.getName();

            Optional<DataAccessRequest> requestOpt = accessRequestRepository.findById(id);
            if (requestOpt.isEmpty()) {
                return ResponseEntity.notFound().build();
            }

            DataAccessRequest request = requestOpt.get();
            request.setStatus(status);
            request.setReviewNotes(reviewNotes);
            request.setReviewedBy(reviewerUsername);
            request.setReviewedAt(LocalDateTime.now());

            if (status == DataAccessRequest.Status.APPROVED && accessGrantedUntilStr != null) {
                LocalDateTime accessUntil = LocalDateTime.parse(accessGrantedUntilStr + "T23:59:59");
                request.setAccessGrantedUntil(accessUntil);
            }

            DataAccessRequest reviewed = accessRequestRepository.save(request);

            return ResponseEntity.ok(Map.of(
                    "message", "Request reviewed successfully",
                    "request", reviewed));

        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "error", "Review failed: " + e.getMessage()));
        }
    }

    @GetMapping("/datasource/{datasourceId}")
    @PreAuthorize("hasRole('ADMIN') or hasRole('DATA_PROVIDER')")
    public ResponseEntity<List<DataAccessRequest>> getRequestsForDatasource(@PathVariable Long datasourceId) {
        Optional<Datasource> datasourceOpt = datasourceService.getDatasourceById(datasourceId);
        if (datasourceOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        List<DataAccessRequest> requests = accessRequestRepository.findByDatasource(datasourceOpt.get());
        return ResponseEntity.ok(requests);
    }
}