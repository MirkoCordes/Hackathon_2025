package de.eq3.hackathon.kreisverwaltung.dto;

import de.eq3.hackathon.kreisverwaltung.entity.Certificate;
import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

@Data
public class CertificateUploadRequest {
    private Certificate.CertificateType type;
    private String description;
    private MultipartFile file;
    private String validUntilString; // Format: "2025-12-31" (optional)
}