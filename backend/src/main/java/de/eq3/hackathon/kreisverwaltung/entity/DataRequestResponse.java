package de.eq3.hackathon.kreisverwaltung.entity;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.ToString;

import java.time.LocalDateTime;

@Entity
@Table(name = "data_request_responses")
@Data
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(exclude = { "dataRequest", "responder", "existingDatasource" })
@ToString(exclude = { "dataRequest", "responder", "existingDatasource" })
public class DataRequestResponse {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "data_request_id", nullable = false)
    @JsonBackReference("datarequest-responses")
    private DataRequest dataRequest;

    @ManyToOne
    @JoinColumn(name = "responder_id", nullable = false)
    @JsonBackReference("user-dataresponses")
    private User responder; // Wer antwortet auf den Datenwunsch?

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ResponseType responseType;

    @Column(length = 1000, nullable = false)
    private String message; // Nachricht des Anbieters

    // === FÜR BESTEHENDE DATENQUELLEN ===
    @ManyToOne
    @JoinColumn(name = "existing_datasource_id")
    private Datasource existingDatasource; // Falls bereits eine passende Datenquelle existiert

    // === FÜR NEUE DATENQUELLEN ===
    @Column
    private String proposedTitle; // Titel der vorgeschlagenen neuen Datenquelle

    @Column(length = 1000)
    private String proposedDescription; // Beschreibung der geplanten Datenquelle

    @Column
    private String estimatedDeliveryTime; // Wann könnte die Datenquelle bereitgestellt werden?

    @Column
    private String estimatedCost; // Kosten (falls relevant)

    @Enumerated(EnumType.STRING)
    private Datasource.DataFormat proposedFormat; // Geplantes Datenformat

    @Enumerated(EnumType.STRING)
    private Datasource.AccessLevel proposedAccessLevel; // Geplantes Zugriffslevel

    // === STATUS & METADATA ===
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Status status = Status.PENDING;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    @Column
    private LocalDateTime lastUpdated;

    @Column
    private String contactEmail; // Kontakt für Rückfragen

    @Column
    private String contactPhone; // Optional: Telefonnummer

    public enum ResponseType {
        EXISTING_DATASOURCE("Bestehende Datenquelle", "Ich habe bereits eine passende Datenquelle"),
        NEW_DATASOURCE("Neue Datenquelle", "Ich kann eine neue Datenquelle erstellen"),
        PARTIAL_MATCH("Teilweise passend", "Meine Datenquelle erfüllt den Bedarf teilweise"),
        COLLABORATION("Kooperation", "Ich möchte bei der Lösung mithelfen"),
        INFORMATION("Information", "Ich habe weitere Informationen dazu");

        private final String displayName;
        private final String description;

        ResponseType(String displayName, String description) {
            this.displayName = displayName;
            this.description = description;
        }

        public String getDisplayName() {
            return displayName;
        }

        public String getDescription() {
            return description;
        }
    }

    public enum Status {
        PENDING("Ausstehend", "warning"),
        ACCEPTED("Akzeptiert", "success"),
        REJECTED("Abgelehnt", "danger"),
        IN_PROGRESS("In Bearbeitung", "info"),
        COMPLETED("Abgeschlossen", "primary"),
        WITHDRAWN("Zurückgezogen", "secondary");

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
        lastUpdated = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        lastUpdated = LocalDateTime.now();
    }

    // === HELPER METHODS ===
    public boolean isForExistingDatasource() {
        return responseType == ResponseType.EXISTING_DATASOURCE && existingDatasource != null;
    }

    public boolean isForNewDatasource() {
        return responseType == ResponseType.NEW_DATASOURCE && proposedTitle != null;
    }

    public boolean isPending() {
        return status == Status.PENDING;
    }

    public boolean isAccepted() {
        return status == Status.ACCEPTED;
    }

    public boolean isOwnedBy(User user) {
        return this.responder != null && this.responder.getId().equals(user.getId());
    }

    public String getFormattedAge() {
        if (createdAt == null)
            return "Unbekannt";

        long hours = java.time.temporal.ChronoUnit.HOURS.between(createdAt, LocalDateTime.now());
        if (hours < 1)
            return "Gerade eben";
        if (hours < 24)
            return hours + " Stunden";

        long days = java.time.temporal.ChronoUnit.DAYS.between(createdAt, LocalDateTime.now());
        if (days == 1)
            return "Gestern";
        if (days < 7)
            return days + " Tage";
        return (days / 7) + " Wochen";
    }

    public String getProposedOrExistingTitle() {
        if (isForExistingDatasource()) {
            return existingDatasource.getTitle();
        }
        return proposedTitle;
    }

    public String getProposedOrExistingDescription() {
        if (isForExistingDatasource()) {
            return existingDatasource.getDescription();
        }
        return proposedDescription;
    }
}