package de.eq3.hackathon.kreisverwaltung.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "data_access_requests")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DataAccessRequest {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne
    @JoinColumn(name = "datasource_id", nullable = false)
    private Datasource datasource;

    @ManyToOne
    @JoinColumn(name = "certificate_id", nullable = false)
    private Certificate certificate;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Status status = Status.PENDING;

    @Column(length = 1000)
    private String requestReason; // Why does the user need the data?

    @Column(length = 1000)
    private String intendedUse; // What will the data be used for?

    @Column(length = 1000)
    private String reviewNotes; // Notes from the reviewer

    @Column
    private String reviewedBy; // Username of the reviewer

    @Column
    private LocalDateTime reviewedAt; // When reviewed

    @Column
    private LocalDateTime accessGrantedUntil; // Access valid until

    @Column(nullable = false)
    private LocalDateTime requestedAt;

    public enum Status {
        PENDING("Wartend auf Prüfung"),
        UNDER_REVIEW("In Prüfung"),
        APPROVED("Zugang gewährt"),
        REJECTED("Abgelehnt"),
        EXPIRED("Zugang abgelaufen"),
        REVOKED("Zugang entzogen");

        private final String displayName;

        Status(String displayName) {
            this.displayName = displayName;
        }

        public String getDisplayName() {
            return displayName;
        }
    }

    @PrePersist
    protected void onCreate() {
        requestedAt = LocalDateTime.now();
    }

    // Helper methods
    public boolean hasActiveAccess() {
        return status == Status.APPROVED &&
                (accessGrantedUntil == null || accessGrantedUntil.isAfter(LocalDateTime.now()));
    }
}