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
    private String fileName; // Original Dateiname

    @Column(nullable = false)
    private String filePath; // Pfad zur gespeicherten Datei

    @Column(nullable = false)
    private String fileType; // MIME-Type (application/pdf, image/jpeg, etc.)

    @Column
    private Long fileSize; // Dateigröße in Bytes

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Status status = Status.PENDING;

    @Column(length = 1000)
    private String description; // Beschreibung vom Nutzer

    @Column(length = 1000)
    private String reviewNotes; // Notizen vom Prüfer

    @Column
    private String reviewedBy; // Username des Prüfers

    @Column
    private LocalDateTime reviewedAt; // Wann geprüft

    @Column
    private LocalDateTime validUntil; // Gültig bis (falls Zertifikat Ablaufdatum hat)

    @Column(nullable = false)
    private LocalDateTime uploadedAt;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    // === AUTOMATISCHE ABLAUF-ÜBERWACHUNG ===
    @Column
    private Boolean notificationSent = false; // Wurden Ablauf-Warnungen versendet?

    @Column
    private LocalDateTime lastNotificationSent; // Wann letzte Warnung versendet

    public enum CertificateType {
        // === BEHÖRDLICHE ZERTIFIKATE ===
        GOVERNMENT_GENERAL("Behörde Allgemein", "Allgemeiner Behördennachweis"),
        GOVERNMENT_ENVIRONMENT("Behörde Umwelt", "Umweltbehörde, Wasserwirtschaft"),
        GOVERNMENT_HEALTH("Behörde Gesundheit", "Gesundheitsamt, Seuchenschutz"),
        GOVERNMENT_STATISTICS("Behörde Statistik", "Statistisches Amt"),
        GOVERNMENT_PLANNING("Behörde Planung", "Stadtplanung, Raumordnung"),

        // === FORSCHUNGSZERTIFIKATE ===
        RESEARCH_UNIVERSITY("Universität", "Hochschul-Zugehörigkeit"),
        RESEARCH_ENVIRONMENTAL("Umweltforschung", "Institute für Umwelt- und Klimaforschung"),
        RESEARCH_HEALTH("Medizinische Forschung", "Medizinische Fakultäten, Kliniken"),
        RESEARCH_SOCIAL("Sozialforschung", "Soziologie, Demographie"),
        RESEARCH_ECONOMIC("Wirtschaftsforschung", "Wirtschaftsinstitute"),

        // === BERUFSZERTIFIKATE ===
        PROFESSIONAL_LAWYER("Rechtsanwalt", "Anwaltskammer-Zulassung"),
        PROFESSIONAL_DOCTOR("Arzt/Mediziner", "Ärztekammer-Zulassung"),
        PROFESSIONAL_ENGINEER("Ingenieur", "Ingenieurskammer, Sachverständiger"),
        PROFESSIONAL_JOURNALIST("Journalist", "Presseausweis"),
        PROFESSIONAL_CONSULTANT("Berater", "Zertifizierte Beratung"),

        // === UNTERNEHMENSZERTIFIKATE ===
        BUSINESS_GENERAL("Unternehmen Allgemein", "Gewerbeschein, Handelsregister"),
        BUSINESS_ENVIRONMENTAL("Umweltunternehmen", "Umwelttechnik, Entsorgung"),
        BUSINESS_HEALTHCARE("Gesundheitsunternehmen", "Pharma, Medizintechnik"),
        BUSINESS_CONSULTING("Beratungsunternehmen", "Zertifizierte Unternehmensberatung"),
        BUSINESS_MEDIA("Medienunternehmen", "Presse, Rundfunk, Online-Medien"),

        // === ZIVILGESELLSCHAFT ===
        NGO_ENVIRONMENTAL("Umwelt-NGO", "Greenpeace, NABU, etc."),
        NGO_SOCIAL("Soziale NGO", "Caritas, DRK, etc."),
        NGO_TRANSPARENCY("Transparenz-NGO", "FragDenStaat, Lobbycontrol"),

        // === BASIS-NACHWEISE ===
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

        // Hilfsmethoden für Kategorisierung
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

    // Hilfsmethoden
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
            return -1; // Kein Ablaufdatum
        return java.time.temporal.ChronoUnit.DAYS.between(LocalDateTime.now(), validUntil);
    }
}