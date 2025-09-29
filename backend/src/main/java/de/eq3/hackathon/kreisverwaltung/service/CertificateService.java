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
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;

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

        // Read uploaded bytes into memory (files are limited to 10MB in validate)
        byte[] bytes = file.getBytes();

        // Detect content type from bytes and filename, then validate
        String detectedContentType = detectContentType(bytes, file.getOriginalFilename(), file.getContentType());
        validateFile(bytes, detectedContentType);

        // Save file (files are stored under uploadDir, default ./uploads/certificates/)
        String fileName = saveFileBytes(bytes, file.getOriginalFilename());

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
        try {
            byte[] bytes = file.getBytes();
            validateFile(bytes, detectedContentType != null ? detectedContentType : file.getContentType());
        } catch (IOException e) {
            throw new RuntimeException("Unable to read uploaded file for validation: " + e.getMessage());
        }
    }

    private String detectContentType(MultipartFile file) {
        try {
            byte[] bytes = file.getBytes();
            return detectContentType(bytes, file.getOriginalFilename(), file.getContentType());
        } catch (Exception e) {
            // fallback to original header or octet-stream
            String ct = file.getContentType();
            return ct != null ? ct : "application/octet-stream";
        }
    }

    // New overload: detect content type from byte[] and filename/contentType hints
    private String detectContentType(byte[] bytes, String originalFilename, String providedContentType) {
        // 1) client provided
        if (providedContentType != null && !providedContentType.equals("application/octet-stream")) {
            return providedContentType;
        }

        // 2) try guessing from bytes (URLConnection.guessContentTypeFromStream expects an InputStream)
        try (InputStream is = new BufferedInputStream(new java.io.ByteArrayInputStream(bytes))) {
            String guessed = URLConnection.guessContentTypeFromStream(is);
            if (guessed != null) {
                return guessed;
            }
        } catch (Exception e) {
            // ignore
        }

        // 3) try probe content type by writing to a temp file with the given suffix
        Path tempFile = null;
        try {
            String suffix = originalFilename != null && originalFilename.contains(".") ? originalFilename.substring(originalFilename.lastIndexOf('.')) : null;
            tempFile = Files.createTempFile("upload-probe-", suffix == null ? null : suffix);
            Files.write(tempFile, bytes);
            String probe = Files.probeContentType(tempFile);
            if (probe != null) return probe;
        } catch (Exception e) {
            // ignore
        } finally {
            try {
                if (tempFile != null) Files.deleteIfExists(tempFile);
            } catch (Exception ignore) {}
        }

        // fallback
        return "application/octet-stream";
    }

    private void validateFile(byte[] bytes, String detectedContentType) {
        if (bytes == null || bytes.length == 0) {
            throw new RuntimeException("File is empty");
        }

        long maxSize = 10 * 1024 * 1024;
        if (bytes.length > maxSize) {
            throw new RuntimeException("File size exceeds 10MB limit");
        }

        String contentType = detectedContentType;
        if (contentType == null || (
            !contentType.equals("application/pdf") &&
                !contentType.equals("application/x-pdf") &&
                !contentType.startsWith("image/jpeg") &&
                !contentType.startsWith("image/jpg") &&
                !contentType.startsWith("image/png"))) {
            throw new RuntimeException("Only PDF, JPEG and PNG files are allowed (detected: " + contentType + ")");
        }
    }

    private String saveFileBytes(byte[] bytes, String originalFilename) throws IOException {
        // Create upload directory if not exists
        Path uploadPath = Paths.get(uploadDir);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }

        String extension = originalFilename != null && originalFilename.contains(".") ? originalFilename.substring(originalFilename.lastIndexOf('.')) : "";
        String fileName = UUID.randomUUID().toString() + extension;
        Path filePath = uploadPath.resolve(fileName);
        Files.write(filePath, bytes);
        return fileName;
    }

    public Optional<Resource> getCertificateResource(Long certificateId) {
        Optional<Certificate> certOpt = certificateRepository.findById(certificateId);
        if (certOpt.isEmpty()) return Optional.empty();

        Certificate cert = certOpt.get();
        try {
            Path filePath = Paths.get(uploadDir).resolve(cert.getFilePath());
            Resource resource = new UrlResource(filePath.toUri());
            if (resource.exists() && resource.isReadable()) {
                return Optional.of(resource);
            }
        } catch (Exception e) {
            // ignore and return empty
        }
        return Optional.empty();
    }
}