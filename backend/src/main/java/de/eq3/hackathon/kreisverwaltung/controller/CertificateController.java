package de.eq3.hackathon.kreisverwaltung.controller;

import de.eq3.hackathon.kreisverwaltung.entity.Certificate;
import de.eq3.hackathon.kreisverwaltung.entity.User;
import de.eq3.hackathon.kreisverwaltung.service.CertificateService;
import de.eq3.hackathon.kreisverwaltung.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/certificates")
@RequiredArgsConstructor
@Tag(name = "Certificates", description = "Zertifikatsverwaltung - Upload, Prüfung und Verwaltung von Zugangszertifikaten")
public class CertificateController {

    private final CertificateService certificateService;
    private final UserService userService;

    @PostMapping("/upload")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Zertifikat hochladen", description = "Lädt ein neues Zertifikat hoch (PDF, JPG oder PNG, max 10MB). Das Zertifikat wird zur Prüfung eingereicht.")
    @ApiResponse(responseCode = "200", description = "Zertifikat erfolgreich hochgeladen")
    @ApiResponse(responseCode = "400", description = "Ungültige Datei oder Parameter")
    @ApiResponse(responseCode = "401", description = "Nicht authentifiziert")
    public ResponseEntity<?> uploadCertificate(
            @Parameter(description = "Zertifikatsdatei (PDF, JPG, PNG, max 10MB)", required = true) @RequestParam("file") MultipartFile file,

            @Parameter(description = "Art des Zertifikats", required = true) @RequestParam("type") Certificate.CertificateType type,

            @Parameter(description = "Beschreibung des Zertifikats", required = true) @RequestParam("description") String description,

            @Parameter(description = "Gültig bis (Format: YYYY-MM-DD)", required = false) @RequestParam(value = "validUntil", required = false) String validUntilStr) {

        try {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            User currentUser = userService.findByUsername(auth.getName()).orElse(null);

            if (currentUser == null) {
                return ResponseEntity.status(401).body("User not found");
            }

            LocalDateTime validUntil = null;
            if (validUntilStr != null && !validUntilStr.isEmpty()) {
                validUntil = LocalDateTime.parse(validUntilStr + "T23:59:59");
            }

            Certificate certificate = certificateService.uploadCertificate(
                    currentUser, type, description, file, validUntil);

            return ResponseEntity.ok(Map.of(
                    "message", "Certificate uploaded successfully",
                    "certificateId", certificate.getId(),
                    "status", certificate.getStatus()));

        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "error", "Upload failed: " + e.getMessage()));
        }
    }

    @GetMapping("/my")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Meine Zertifikate", description = "Zeigt alle Zertifikate des aktuell angemeldeten Nutzers")
    public ResponseEntity<List<Certificate>> getMyCertificates() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User currentUser = userService.findByUsername(auth.getName()).orElse(null);

        if (currentUser == null) {
            return ResponseEntity.status(401).build();
        }

        List<Certificate> certificates = certificateService.getCertificatesByUser(currentUser);
        return ResponseEntity.ok(certificates);
    }

    @GetMapping("/my/active")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<List<Certificate>> getMyActiveCertificates() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User currentUser = userService.findByUsername(auth.getName()).orElse(null);

        if (currentUser == null) {
            return ResponseEntity.status(401).build();
        }

        List<Certificate> certificates = certificateService.getActiveCertificatesByUser(currentUser);
        return ResponseEntity.ok(certificates);
    }

    @GetMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Certificate> getCertificate(@PathVariable Long id) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User currentUser = userService.findByUsername(auth.getName()).orElse(null);

        Optional<Certificate> certificate = certificateService.getCertificateById(id);

        if (certificate.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Certificate cert = certificate.get();

        // Nur eigene Zertifikate oder Admin/Reviewer können alle sehen
        if (!cert.getUser().equals(currentUser) &&
                currentUser != null &&
                currentUser.getRole() != User.Role.ADMIN &&
                currentUser.getRole() != User.Role.REVIEWER) {
            return ResponseEntity.status(403).build();
        }

        return ResponseEntity.ok(cert);
    }

    @GetMapping("/types")
    public ResponseEntity<Certificate.CertificateType[]> getCertificateTypes() {
        return ResponseEntity.ok(Certificate.CertificateType.values());
    }

    @GetMapping("/categories")
    public ResponseEntity<Certificate.CertificateCategory[]> getCertificateCategories() {
        return ResponseEntity.ok(Certificate.CertificateCategory.values());
    }

    // === ADMIN/REVIEWER ENDPOINTS ===

    @GetMapping("/pending")
    @PreAuthorize("hasRole('ADMIN') or hasRole('REVIEWER')")
    public ResponseEntity<List<Certificate>> getPendingCertificates() {
        List<Certificate> pending = certificateService.getPendingCertificates();
        return ResponseEntity.ok(pending);
    }

    @GetMapping("/all")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<Certificate>> getAllCertificates() {
        List<Certificate> all = certificateService.getAllCertificates();
        return ResponseEntity.ok(all);
    }

    @PostMapping("/{id}/review")
    @PreAuthorize("hasRole('ADMIN') or hasRole('REVIEWER')")
    public ResponseEntity<?> reviewCertificate(
            @PathVariable Long id,
            @RequestParam Certificate.Status status,
            @RequestParam(required = false) String reviewNotes) {

        try {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            String reviewerUsername = auth.getName();

            Certificate reviewed = certificateService.reviewCertificate(
                    id, status, reviewNotes, reviewerUsername);

            return ResponseEntity.ok(Map.of(
                    "message", "Certificate reviewed successfully",
                    "certificate", reviewed));

        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "error", "Review failed: " + e.getMessage()));
        }
    }

    @GetMapping("/expiring-soon")
    @PreAuthorize("hasRole('ADMIN') or hasRole('REVIEWER')")
    public ResponseEntity<List<Certificate>> getExpiringSoonCertificates() {
        List<Certificate> expiring = certificateService.getExpiringSoonCertificates();
        return ResponseEntity.ok(expiring);
    }

    @PostMapping("/update-expired")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> updateExpiredCertificates() {
        certificateService.updateExpiredCertificates();
        return ResponseEntity.ok(Map.of("message", "Expired certificates updated"));
    }
}