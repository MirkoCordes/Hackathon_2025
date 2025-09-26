package de.eq3.hackathon.kreisverwaltung.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User implements UserDetails {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String username;

    @Column(unique = true, nullable = false)
    private String email;

    @Column(nullable = false)
    private String password;

    @Enumerated(EnumType.STRING)
    private Role role = Role.USER;

    private boolean enabled = true;

    // === ZUSÄTZLICHE PROFILE INFORMATIONEN ===
    @Column
    private String firstName;

    @Column
    private String lastName;

    @Column
    private String organization; // Firma/Institution des Nutzers

    @Column
    private String jobTitle; // Berufsbezeichnung

    // === BEZIEHUNGEN ===
    @OneToMany(mappedBy = "user", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    private List<Certificate> certificates = new ArrayList<>();

    @OneToMany(mappedBy = "user", fetch = FetchType.LAZY)
    private List<DataAccessRequest> accessRequests = new ArrayList<>();

    public enum Role {
        USER("Nutzer"),
        ADMIN("Administrator"),
        DATA_PROVIDER("Datenanbieter"),
        REVIEWER("Zertifikatsprüfer");

        private final String displayName;

        Role(String displayName) {
            this.displayName = displayName;
        }

        public String getDisplayName() {
            return displayName;
        }
    }

    // === HILFSMETHODEN ===
    public List<Certificate> getActiveCertificates() {
        return certificates.stream()
                .filter(Certificate::isActive)
                .toList();
    }

    public boolean hasActiveCertificateOfType(Certificate.CertificateType type) {
        return certificates.stream()
                .anyMatch(cert -> cert.getType() == type && cert.isActive());
    }

    public boolean canAccessDatasource(Datasource datasource) {
        // Öffentliche Datenquellen sind für alle zugänglich
        if (datasource.getAccessLevel() == Datasource.AccessLevel.PUBLIC) {
            return true;
        }

        // Keine Zertifikate erforderlich
        if (!datasource.getRequiresCertificate() || datasource.getRequiredCertificateTypes().isEmpty()) {
            return true;
        }

        // Prüfe ob User eines der erforderlichen Zertifikate hat
        return datasource.getRequiredCertificateTypes().stream()
                .anyMatch(this::hasActiveCertificateOfType);
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(new SimpleGrantedAuthority("ROLE_" + role.name()));
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return enabled;
    }
}