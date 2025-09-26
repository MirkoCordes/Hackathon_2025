package de.eq3.hackathon.kreisverwaltung.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "certificates")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Certificate {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private CertificateType type;

    @Column(nullable = false)
    private String fileName; // Original filename

    @Column(nullable = false)
    private String filePath; // Path to stored file

    @Column(nullable = false)
    private String fileType; // MIME type (application/pdf, image/jpeg, etc.)

    @Column
    private Long fileSize; // File size in bytes

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Status status = Status.PENDING;

    @Column(length = 1000)
    private String description; // Description from user

    @Column(length = 1000)
    private String reviewNotes; // Review notes from reviewer

    @Column
    private String reviewedBy; // Username of reviewer

    @Column
    private LocalDateTime reviewedAt; // When reviewed

    @Column
    private LocalDateTime validUntil; // Valid until (if certificate has expiry date)

    @Column(nullable = false)
    private LocalDateTime uploadedAt;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    // === AUTOMATIC EXPIRY MONITORING ===
    @Column
    private Boolean notificationSent = false; // Were expiry warnings sent?

    @Column
    private LocalDateTime lastNotificationSent; // When last warning was sent

    public enum CertificateType {
        // === GOVERNMENT CERTIFICATES ===
        GOVERNMENT_GENERAL("Behörde Allgemein", "Allgemeiner Behördennachweis"),
        GOVERNMENT_ENVIRONMENT("Behörde Umwelt", "Umweltbehörde, Wasserwirtschaft"),
        GOVERNMENT_HEALTH("Behörde Gesundheit", "Gesundheitsamt, Seuchenschutz"),
        GOVERNMENT_STATISTICS("Behörde Statistik", "Statistisches Amt"),
        GOVERNMENT_PLANNING("Behörde Planung", "Stadtplanung, Raumordnung"),

        // === RESEARCH CERTIFICATES ===
        RESEARCH_UNIVERSITY("Universität", "Hochschul-Zugehörigkeit"),
        RESEARCH_ENVIRONMENTAL("Umweltforschung", "Institute für Umwelt- und Klimaforschung"),
        RESEARCH_HEALTH("Medizinische Forschung", "Medizinische Fakultäten, Kliniken"),
        RESEARCH_SOCIAL("Sozialforschung", "Soziologie, Demographie"),
        RESEARCH_ECONOMIC("Wirtschaftsforschung", "Wirtschaftsinstitute"),

        // === PROFESSIONAL CERTIFICATES ===
        PROFESSIONAL_LAWYER("Rechtsanwalt", "Anwaltskammer-Zulassung"),
        PROFESSIONAL_DOCTOR("Arzt/Mediziner", "Ärztekammer-Zulassung"),
        PROFESSIONAL_ENGINEER("Ingenieur", "Ingenieurskammer, Sachverständiger"),
        PROFESSIONAL_JOURNALIST("Journalist", "Presseausweis"),
        PROFESSIONAL_CONSULTANT("Berater", "Zertifizierte Beratung"),

        // === BUSINESS CERTIFICATES ===
        BUSINESS_GENERAL("Unternehmen Allgemein", "Gewerbeschein, Handelsregister"),
        BUSINESS_ENVIRONMENTAL("Umweltunternehmen", "Umwelttechnik, Entsorgung"),
        BUSINESS_HEALTHCARE("Gesundheitsunternehmen", "Pharma, Medizintechnik"),
        BUSINESS_CONSULTING("Beratungsunternehmen", "Zertifizierte Unternehmensberatung"),
        BUSINESS_MEDIA("Medienunternehmen", "Presse, Rundfunk, Online-Medien"),

        // === CIVIL SOCIETY ===
        NGO_ENVIRONMENTAL("Umwelt-NGO", "Greenpeace, NABU, etc."),
        NGO_SOCIAL("Soziale NGO", "Caritas, DRK, etc."),
        NGO_TRANSPARENCY("Transparenz-NGO", "FragDenStaat, Lobbycontrol"),

        // === BASIC PROOFS ===
        PERSONAL_ID("Personalausweis", "Amtlicher Lichtbildausweis"),
        OTHER("Sonstiges", "Andere Nachweise");

        private final String displayName;
        private final String description;

        CertificateType(String displayName, String description) {
            this.displayName = displayName;
            this.description = description;
        }

        public String getDisplayName() {
            return displayName;
        }

        public String getDescription() {
            return description;
        }

        // Helper methods for categorization
        public CertificateCategory getCategory() {
            if (name().startsWith("GOVERNMENT_"))
                return CertificateCategory.GOVERNMENT;
            if (name().startsWith("RESEARCH_"))
                return CertificateCategory.RESEARCH;
            if (name().startsWith("PROFESSIONAL_"))
                return CertificateCategory.PROFESSIONAL;
            if (name().startsWith("BUSINESS_"))
                return CertificateCategory.BUSINESS;
            if (name().startsWith("NGO_"))
                return CertificateCategory.NGO;
            return CertificateCategory.OTHER;
        }

        public boolean isEnvironmentalCertificate() {
            return name().contains("ENVIRONMENT");
        }

        public boolean isHealthCertificate() {
            return name().contains("HEALTH");
        }
    }

    public enum CertificateCategory {
        GOVERNMENT("Behörden"),
        RESEARCH("Forschung"),
        PROFESSIONAL("Berufe"),
        BUSINESS("Unternehmen"),
        NGO("NGOs/Vereine"),
        OTHER("Sonstige");

        private final String displayName;

        CertificateCategory(String displayName) {
            this.displayName = displayName;
        }

        public String getDisplayName() {
            return displayName;
        }
    }

    public enum Status {
        PENDING("Wartend auf Prüfung", "warning"),
        UNDER_REVIEW("In Prüfung", "info"),
        APPROVED("Genehmigt", "success"),
        REJECTED("Abgelehnt", "danger"),
        EXPIRED("Abgelaufen", "secondary");

        private final String displayName;
        private final String cssClass;

        Status(String displayName, String cssClass) {
            this.displayName = displayName;
            this.cssClass = cssClass;
        }

        public String getDisplayName() {
            return displayName;
        }

        public String getCssClass() {
            return cssClass;
        }
    }

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        if (uploadedAt == null) {
            uploadedAt = LocalDateTime.now();
        }
    }

    // Helper methods
    public boolean isActive() {
        return status == Status.APPROVED &&
                (validUntil == null || validUntil.isAfter(LocalDateTime.now()));
    }

    public boolean needsReview() {
        return status == Status.PENDING || status == Status.UNDER_REVIEW;
    }

    public boolean isExpiringSoon() {
        return validUntil != null &&
                validUntil.isAfter(LocalDateTime.now()) &&
                validUntil.isBefore(LocalDateTime.now().plusDays(30));
    }

    public boolean isExpired() {
        return validUntil != null && validUntil.isBefore(LocalDateTime.now());
    }

    public long getDaysUntilExpiry() {
        if (validUntil == null)
            return -1; // No expiry date
        return java.time.temporal.ChronoUnit.DAYS.between(LocalDateTime.now(), validUntil);
    }
}