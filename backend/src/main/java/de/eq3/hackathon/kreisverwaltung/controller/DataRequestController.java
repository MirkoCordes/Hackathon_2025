package de.eq3.hackathon.kreisverwaltung.controller;

import de.eq3.hackathon.kreisverwaltung.entity.DataRequest;
import de.eq3.hackathon.kreisverwaltung.entity.DataRequestResponse;
import de.eq3.hackathon.kreisverwaltung.entity.Datasource;
import de.eq3.hackathon.kreisverwaltung.entity.User;
import de.eq3.hackathon.kreisverwaltung.repository.DataRequestRepository;
import de.eq3.hackathon.kreisverwaltung.repository.DataRequestResponseRepository;
import de.eq3.hackathon.kreisverwaltung.service.DatasourceService;
import de.eq3.hackathon.kreisverwaltung.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/data-marketplace")
@RequiredArgsConstructor
public class DataRequestController {

    private final DataRequestRepository dataRequestRepository;
    private final DataRequestResponseRepository responseRepository;
    private final UserService userService;
    private final DatasourceService datasourceService;

    // === MARKETPLACE OVERVIEW ===

    @GetMapping
    public ResponseEntity<List<DataRequest>> getMarketplace(
            @RequestParam(defaultValue = "OPEN") DataRequest.Status status,
            @RequestParam(required = false) Datasource.Category category,
            @RequestParam(required = false) String search) {

        List<DataRequest> requests;

        if (search != null && !search.trim().isEmpty()) {
            requests = dataRequestRepository.searchByKeywordAndStatus(search.trim(), status);
        } else if (category != null) {
            requests = dataRequestRepository.findByCategoryOrderByCreatedAtDesc(category);
        } else {
            requests = dataRequestRepository.findByStatusOrderByCreatedAtDesc(status);
        }

        return ResponseEntity.ok(requests);
    }

    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getMarketplaceStats() {
        Map<String, Object> stats = Map.of(
                "totalOpenRequests", dataRequestRepository.findByStatus(DataRequest.Status.OPEN).size(),
                "totalFulfilledRequests", dataRequestRepository.findByStatus(DataRequest.Status.FULFILLED).size(),
                "recentRequests", dataRequestRepository.findRecentRequests(LocalDateTime.now().minusDays(7)).size(),
                "popularRequests", dataRequestRepository.findPopularOpenRequests().stream().limit(5).toList(),
                "requestsWithoutResponses",
                dataRequestRepository.findOpenRequestsWithoutResponses().stream().limit(10).toList());
        return ResponseEntity.ok(stats);
    }

    // === DATA REQUEST CRUD ===

    @PostMapping("/requests")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<?> createDataRequest(@RequestBody DataRequest request) {
        try {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            User currentUser = userService.findByUsername(auth.getName()).orElse(null);

            if (currentUser == null) {
                return ResponseEntity.status(401).body("User not found");
            }

            // Set user and metadata
            request.setUser(currentUser);
            request.setCreatedAt(LocalDateTime.now());
            request.setLastUpdated(LocalDateTime.now());

            // Validate required fields
            if (request.getTitle() == null || request.getTitle().trim().isEmpty()) {
                return ResponseEntity.badRequest().body("Titel ist erforderlich");
            }
            if (request.getDescription() == null || request.getDescription().trim().isEmpty()) {
                return ResponseEntity.badRequest().body("Beschreibung ist erforderlich");
            }

            DataRequest savedRequest = dataRequestRepository.save(request);
            return ResponseEntity.ok(savedRequest);

        } catch (Exception e) {
            return ResponseEntity.status(500).body("Fehler beim Erstellen des Datenwunsches: " + e.getMessage());
        }
    }

    @GetMapping("/requests/{id}")
    public ResponseEntity<DataRequest> getDataRequest(@PathVariable Long id) {
        Optional<DataRequest> request = dataRequestRepository.findById(id);
        return request.map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/requests/{id}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<?> updateDataRequest(@PathVariable Long id, @RequestBody DataRequest updatedRequest) {
        Optional<DataRequest> existingOpt = dataRequestRepository.findById(id);
        if (existingOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        DataRequest existing = existingOpt.get();
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User currentUser = userService.findByUsername(auth.getName()).orElse(null);

        // Check ownership or admin rights
        if (currentUser == null || (!existing.isOwnedBy(currentUser) && currentUser.getRole() != User.Role.ADMIN)) {
            return ResponseEntity.status(403).body("Keine Berechtigung zum Bearbeiten");
        }

        // Update fields
        existing.setTitle(updatedRequest.getTitle());
        existing.setDescription(updatedRequest.getDescription());
        existing.setCategory(updatedRequest.getCategory());
        existing.setPriority(updatedRequest.getPriority());
        existing.setIntendedUse(updatedRequest.getIntendedUse());
        existing.setPreferredFormat(updatedRequest.getPreferredFormat());
        existing.setGeographicScope(updatedRequest.getGeographicScope());
        existing.setTimeScope(updatedRequest.getTimeScope());
        existing.setDataSize(updatedRequest.getDataSize());
        existing.setUpdateFrequency(updatedRequest.getUpdateFrequency());
        existing.setContactEmail(updatedRequest.getContactEmail());
        existing.setLastUpdated(LocalDateTime.now());

        DataRequest saved = dataRequestRepository.save(existing);
        return ResponseEntity.ok(saved);
    }

    @DeleteMapping("/requests/{id}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<?> deleteDataRequest(@PathVariable Long id) {
        Optional<DataRequest> requestOpt = dataRequestRepository.findById(id);
        if (requestOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        DataRequest request = requestOpt.get();
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User currentUser = userService.findByUsername(auth.getName()).orElse(null);

        // Check ownership or admin rights
        if (currentUser == null || (!request.isOwnedBy(currentUser) && currentUser.getRole() != User.Role.ADMIN)) {
            return ResponseEntity.status(403).body("Keine Berechtigung zum Löschen");
        }

        dataRequestRepository.delete(request);
        return ResponseEntity.ok().build();
    }

    // === MY REQUESTS ===

    @GetMapping("/my-requests")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<List<DataRequest>> getMyRequests() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User currentUser = userService.findByUsername(auth.getName()).orElse(null);

        if (currentUser == null) {
            return ResponseEntity.status(401).build();
        }

        List<DataRequest> myRequests = dataRequestRepository.findByUserOrderByCreatedAtDesc(currentUser);
        return ResponseEntity.ok(myRequests);
    }

    // === RESPONSES TO REQUESTS ===

    @PostMapping("/requests/{requestId}/responses")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<?> respondToDataRequest(@PathVariable Long requestId,
            @RequestBody DataRequestResponse response) {
        Optional<DataRequest> requestOpt = dataRequestRepository.findById(requestId);
        if (requestOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        DataRequest dataRequest = requestOpt.get();
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User currentUser = userService.findByUsername(auth.getName()).orElse(null);

        if (currentUser == null) {
            return ResponseEntity.status(401).body("User not found");
        }

        // Check if user already responded
        if (responseRepository.existsByDataRequestAndResponder(dataRequest, currentUser)) {
            return ResponseEntity.badRequest().body("Sie haben bereits auf diesen Datenwunsch geantwortet");
        }

        // Can't respond to own request
        if (dataRequest.isOwnedBy(currentUser)) {
            return ResponseEntity.badRequest().body("Sie können nicht auf Ihren eigenen Datenwunsch antworten");
        }

        // Set metadata
        response.setDataRequest(dataRequest);
        response.setResponder(currentUser);
        response.setCreatedAt(LocalDateTime.now());
        response.setLastUpdated(LocalDateTime.now());

        // Validate existing datasource if referenced
        if (response.getResponseType() == DataRequestResponse.ResponseType.EXISTING_DATASOURCE
                && response.getExistingDatasource() != null) {

            Optional<Datasource> datasourceOpt = datasourceService
                    .getDatasourceById(response.getExistingDatasource().getId());
            if (datasourceOpt.isEmpty()) {
                return ResponseEntity.badRequest().body("Referenzierte Datenquelle nicht gefunden");
            }
            response.setExistingDatasource(datasourceOpt.get());
        }

        DataRequestResponse saved = responseRepository.save(response);
        return ResponseEntity.ok(saved);
    }

    @GetMapping("/requests/{requestId}/responses")
    public ResponseEntity<List<DataRequestResponse>> getResponsesForRequest(@PathVariable Long requestId) {
        Optional<DataRequest> requestOpt = dataRequestRepository.findById(requestId);
        if (requestOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        List<DataRequestResponse> responses = responseRepository
                .findByDataRequestOrderByCreatedAtDesc(requestOpt.get());
        return ResponseEntity.ok(responses);
    }

    @GetMapping("/my-responses")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<List<DataRequestResponse>> getMyResponses() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User currentUser = userService.findByUsername(auth.getName()).orElse(null);

        if (currentUser == null) {
            return ResponseEntity.status(401).build();
        }

        List<DataRequestResponse> myResponses = responseRepository.findByResponderOrderByCreatedAtDesc(currentUser);
        return ResponseEntity.ok(myResponses);
    }

    // === REQUEST STATUS MANAGEMENT ===

    @PostMapping("/requests/{requestId}/close")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<?> closeDataRequest(@PathVariable Long requestId,
            @RequestParam DataRequest.Status status,
            @RequestParam(required = false) String reason) {
        Optional<DataRequest> requestOpt = dataRequestRepository.findById(requestId);
        if (requestOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        DataRequest request = requestOpt.get();
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User currentUser = userService.findByUsername(auth.getName()).orElse(null);

        // Check ownership or admin rights
        if (currentUser == null || (!request.isOwnedBy(currentUser) && currentUser.getRole() != User.Role.ADMIN)) {
            return ResponseEntity.status(403).body("Keine Berechtigung");
        }

        request.setStatus(status);
        request.setClosedAt(LocalDateTime.now());
        request.setClosedReason(reason);
        request.setLastUpdated(LocalDateTime.now());

        DataRequest saved = dataRequestRepository.save(request);
        return ResponseEntity.ok(saved);
    }

    @PostMapping("/responses/{responseId}/accept")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<?> acceptResponse(@PathVariable Long responseId) {
        Optional<DataRequestResponse> responseOpt = responseRepository.findById(responseId);
        if (responseOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        DataRequestResponse response = responseOpt.get();
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User currentUser = userService.findByUsername(auth.getName()).orElse(null);

        // Check if user owns the original request
        if (currentUser == null || !response.getDataRequest().isOwnedBy(currentUser)) {
            return ResponseEntity.status(403).body("Keine Berechtigung");
        }

        response.setStatus(DataRequestResponse.Status.ACCEPTED);
        response.setLastUpdated(LocalDateTime.now());

        // Mark request as in progress
        DataRequest request = response.getDataRequest();
        request.setStatus(DataRequest.Status.IN_PROGRESS);
        request.setLastUpdated(LocalDateTime.now());

        responseRepository.save(response);
        dataRequestRepository.save(request);

        return ResponseEntity.ok(response);
    }
}