package de.eq3.hackathon.kreisverwaltung.service;

import de.eq3.hackathon.kreisverwaltung.entity.Certificate;
import de.eq3.hackathon.kreisverwaltung.entity.User;
import de.eq3.hackathon.kreisverwaltung.repository.CertificateRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class CertificateService {

    private final CertificateRepository certificateRepository;
    private final String uploadDir = "./uploads/certificates/";

    public List<Certificate> getAllCertificates() {
        return certificateRepository.findAll();
    }

    public Optional<Certificate> getCertificateById(Long id) {
        return certificateRepository.findById(id);
    }

    public List<Certificate> getCertificatesByUser(User user) {
        return certificateRepository.findByUser(user);
    }

    public List<Certificate> getActiveCertificatesByUser(User user) {
        return certificateRepository.findByUserAndStatus(user, Certificate.Status.APPROVED);
    }

    public List<Certificate> getPendingCertificates() {
        return certificateRepository.findByStatusIn(List.of(
                Certificate.Status.PENDING, Certificate.Status.UNDER_REVIEW));
    }

    public Certificate uploadCertificate(User user, Certificate.CertificateType type,
            String description, MultipartFile file,
            LocalDateTime validUntil) throws IOException {

        // Datei-Validierung
        validateFile(file);

        // Datei speichern
        String fileName = saveFile(file);

        // Certificate Entity erstellen
        Certificate certificate = new Certificate();
        certificate.setUser(user);
        certificate.setType(type);
        certificate.setDescription(description);
        certificate.setFileName(file.getOriginalFilename());
        certificate.setFilePath(fileName);
        certificate.setFileType(file.getContentType());
        certificate.setFileSize(file.getSize());
        certificate.setValidUntil(validUntil);
        certificate.setUploadedAt(LocalDateTime.now());
        certificate.setStatus(Certificate.Status.PENDING);

        return certificateRepository.save(certificate);
    }

    public Certificate reviewCertificate(Long certificateId, Certificate.Status newStatus,
            String reviewNotes, String reviewerUsername) {
        Certificate certificate = certificateRepository.findById(certificateId)
                .orElseThrow(() -> new RuntimeException("Certificate not found"));

        certificate.setStatus(newStatus);
        certificate.setReviewNotes(reviewNotes);
        certificate.setReviewedBy(reviewerUsername);
        certificate.setReviewedAt(LocalDateTime.now());

        return certificateRepository.save(certificate);
    }

    public List<Certificate> getExpiringSoonCertificates() {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime thirtyDaysFromNow = now.plusDays(30);
        return certificateRepository.findExpiringSoon(now, thirtyDaysFromNow, Certificate.Status.APPROVED);
    }

    public void updateExpiredCertificates() {
        LocalDateTime now = LocalDateTime.now();
        List<Certificate> expired = certificateRepository.findExpired(now, Certificate.Status.APPROVED);

        for (Certificate cert : expired) {
            cert.setStatus(Certificate.Status.EXPIRED);
            certificateRepository.save(cert);
        }
    }

    private void validateFile(MultipartFile file) {
        if (file.isEmpty()) {
            throw new RuntimeException("File is empty");
        }

        // Größenbeschränkung: 10MB
        long maxSize = 10 * 1024 * 1024;
        if (file.getSize() > maxSize) {
            throw new RuntimeException("File size exceeds 10MB limit");
        }

        // Erlaubte Dateitypen
        String contentType = file.getContentType();
        if (contentType == null ||
                (!contentType.equals("application/pdf") &&
                        !contentType.startsWith("image/jpeg") &&
                        !contentType.startsWith("image/png"))) {
            throw new RuntimeException("Only PDF, JPEG and PNG files are allowed");
        }
    }

    private String saveFile(MultipartFile file) throws IOException {
        // Upload-Verzeichnis erstellen falls nicht vorhanden
        Path uploadPath = Paths.get(uploadDir);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }

        // Eindeutigen Dateinamen generieren
        String originalFilename = file.getOriginalFilename();
        String extension = originalFilename != null ? originalFilename.substring(originalFilename.lastIndexOf("."))
                : "";
        String fileName = UUID.randomUUID().toString() + extension;

        // Datei speichern
        Path filePath = uploadPath.resolve(fileName);
        Files.copy(file.getInputStream(), filePath);

        return fileName;
    }
}