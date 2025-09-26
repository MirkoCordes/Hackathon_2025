package de.eq3.hackathon.kreisverwaltung.entity;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.ToString;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "data_requests")
@Data
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(exclude = { "user", "responses" })
@ToString(exclude = { "user", "responses" })
public class DataRequest {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title; // Was für Daten werden gesucht?

    @Column(length = 2000, nullable = false)
    private String description; // Detaillierte Beschreibung des Datenbedarfs

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Datasource.Category category; // Gleiche Kategorien wie Datasources

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Priority priority; // Wie dringend ist der Bedarf?

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Status status = Status.OPEN;

    // === REQUESTER INFO ===
    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    @JsonBackReference("user-datarequests")
    private User user; // Wer hat den Datenwunsch gestellt?

    @Column
    private String contactEmail; // Kontakt-Email (falls anders als User-Email)

    @Column(length = 1000)
    private String intendedUse; // Wofür werden die Daten benötigt?

    // === DATA REQUIREMENTS ===
    @Enumerated(EnumType.STRING)
    private Datasource.DataFormat preferredFormat; // Gewünschtes Datenformat

    @Column
    private String geographicScope; // Geografischer Bereich (z.B. "Ostfriesland", "Niedersachsen")

    @Column
    private String timeScope; // Zeitlicher Bereich (z.B. "2020-2024", "laufend")

    @Column
    private String dataSize; // Ungefähre Datenmenge (z.B. "< 1GB", "mehrere TB")

    @Enumerated(EnumType.STRING)
    private UpdateFrequency updateFrequency; // Wie oft sollen Daten aktualisiert werden?

    // === RESPONSES ===
    @OneToMany(mappedBy = "dataRequest", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @JsonManagedReference("datarequest-responses")
    private List<DataRequestResponse> responses = new ArrayList<>();

    // === METADATA ===
    @Column(nullable = false)
    private LocalDateTime createdAt;

    @Column
    private LocalDateTime lastUpdated;

    @Column
    private LocalDateTime closedAt;

    @Column
    private String closedReason; // Warum wurde der Request geschlossen?

    public enum Priority {
        LOW("Niedrig", "Nice-to-have, kein Zeitdruck"),
        MEDIUM("Mittel", "Wichtig für aktuelle Projekte"),
        HIGH("Hoch", "Dringend benötigt"),
        URGENT("Sehr dringend", "Kritisch für laufende Projekte");

        private final String displayName;
        private final String description;

        Priority(String displayName, String description) {
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
        OPEN("Offen", "success"),
        IN_PROGRESS("In Bearbeitung", "info"),
        FULFILLED("Erfüllt", "primary"),
        CLOSED("Geschlossen", "secondary");

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

    public enum UpdateFrequency {
        ONE_TIME("Einmalig"),
        WEEKLY("Wöchentlich"),
        MONTHLY("Monatlich"),
        QUARTERLY("Vierteljährlich"),
        YEARLY("Jährlich"),
        REAL_TIME("Echtzeit"),
        ON_DEMAND("Bei Bedarf");

        private final String displayName;

        UpdateFrequency(String displayName) {
            this.displayName = displayName;
        }

        public String getDisplayName() {
            return displayName;
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
    public boolean isOpen() {
        return status == Status.OPEN;
    }

    public boolean hasResponses() {
        return !responses.isEmpty();
    }

    public int getResponseCount() {
        return responses.size();
    }

    public List<DataRequestResponse> getActiveResponses() {
        return responses.stream()
                .filter(response -> response.getStatus() != DataRequestResponse.Status.WITHDRAWN)
                .toList();
    }

    public boolean isOwnedBy(User user) {
        return this.user != null && this.user.getId().equals(user.getId());
    }

    public String getFormattedAge() {
        if (createdAt == null)
            return "Unbekannt";

        long days = java.time.temporal.ChronoUnit.DAYS.between(createdAt, LocalDateTime.now());
        if (days == 0)
            return "Heute";
        if (days == 1)
            return "Gestern";
        if (days < 7)
            return days + " Tage";
        if (days < 30)
            return (days / 7) + " Wochen";
        return (days / 30) + " Monate";
    }
}