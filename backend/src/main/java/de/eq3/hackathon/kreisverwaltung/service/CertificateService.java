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
import java.io.BufferedInputStream;
import java.io.InputStream;
import java.net.URLConnection;
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

        // Detect content type and validate the file
        String detectedContentType = detectContentType(file);
        validateFile(file, detectedContentType);

        // Save file (files are stored under uploadDir, default ./uploads/certificates/)
        String fileName = saveFile(file);

        // Create Certificate entity
        Certificate certificate = new Certificate();
        certificate.setUser(user);
        certificate.setType(type);
        certificate.setDescription(description);
        certificate.setFileName(file.getOriginalFilename());
        certificate.setFilePath(fileName);
    // Store the detected content type (more reliable than the client-provided header)
    certificate.setFileType(detectedContentType);
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

    private void validateFile(MultipartFile file, String detectedContentType) {
        if (file.isEmpty()) {
            throw new RuntimeException("File is empty");
        }

        // Size limit: 10MB
        long maxSize = 10 * 1024 * 1024;
        if (file.getSize() > maxSize) {
            throw new RuntimeException("File size exceeds 10MB limit");
        }

    // Use detected content type (provided by caller) or fall back to header
    String contentType = detectedContentType != null ? detectedContentType : file.getContentType();

    // Allowed file types (whitelist)
    if (contentType == null || (
        !contentType.equals("application/pdf") &&
            !contentType.equals("application/x-pdf") &&
            !contentType.startsWith("image/jpeg") &&
            !contentType.startsWith("image/jpg") &&
            !contentType.startsWith("image/png"))) {
        throw new RuntimeException("Only PDF, JPEG and PNG files are allowed (detected: " + contentType + ")");
    }
    }

    private String detectContentType(MultipartFile file) {
        // 1) client provided
        String contentType = file.getContentType();
        if (contentType != null && !contentType.equals("application/octet-stream")) {
            return contentType;
        }

        // 2) try guessing from stream (reads a small portion)
        try (InputStream is = file.getInputStream(); BufferedInputStream bis = new BufferedInputStream(is)) {
            bis.mark(10 * 1024);
            String guessed = URLConnection.guessContentTypeFromStream(bis);
            if (guessed != null) {
                return guessed;
            }
            bis.reset();
        } catch (Exception e) {
            // ignore and try next method
        }

        // 3) try probe content type by writing to a temp file
        Path tempFile = null;
        try {
            String original = file.getOriginalFilename();
            String suffix = original != null && original.contains(".") ? original.substring(original.lastIndexOf('.')) : null;
            tempFile = Files.createTempFile("upload-probe-", suffix == null ? null : suffix);
            file.transferTo(tempFile.toFile());
            String probe = Files.probeContentType(tempFile);
            if (probe != null) return probe;
        } catch (Exception e) {
            // ignore
        } finally {
            try {
                if (tempFile != null) Files.deleteIfExists(tempFile);
            } catch (Exception ignore) {}
        }

        // 4) fallback
        return "application/octet-stream";
    }

    private String saveFile(MultipartFile file) throws IOException {
        // Create upload directory if not exists
        Path uploadPath = Paths.get(uploadDir);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }

        // Generate unique filename
        String originalFilename = file.getOriginalFilename();
        String extension = originalFilename != null ? originalFilename.substring(originalFilename.lastIndexOf("."))
                : "";
        String fileName = UUID.randomUUID().toString() + extension;

        // Save file
        Path filePath = uploadPath.resolve(fileName);
        Files.copy(file.getInputStream(), filePath);

        return fileName;
    }
}