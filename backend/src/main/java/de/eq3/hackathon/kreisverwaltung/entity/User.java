package de.eq3.hackathon.kreisverwaltung.entity;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.ToString;
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
@EqualsAndHashCode(exclude = { "certificates", "accessRequests", "dataRequests", "dataResponses" })
@ToString(exclude = { "certificates", "accessRequests", "dataRequests", "dataResponses" })
public class User implements UserDetails {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String username;

    @Column(unique = true, nullable = false)
    private String email;

    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
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
    private String organization; // Company/Institution of the user

    @Column
    private String jobTitle; // Job title

    // === BEZIEHUNGEN ===
    @OneToMany(mappedBy = "user", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @JsonManagedReference("user-certificates")
    private List<Certificate> certificates = new ArrayList<>();

    @OneToMany(mappedBy = "user", fetch = FetchType.LAZY)
    @JsonBackReference("user-accessrequests")
    private List<DataAccessRequest> accessRequests = new ArrayList<>();

    @OneToMany(mappedBy = "user", fetch = FetchType.LAZY)
    @JsonBackReference("user-datarequests")
    private List<DataRequest> dataRequests = new ArrayList<>();

    @OneToMany(mappedBy = "responder", fetch = FetchType.LAZY)
    @JsonBackReference("user-dataresponses")
    private List<DataRequestResponse> dataResponses = new ArrayList<>();

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
        // Public datasources are accessible to everyone
        if (datasource.getAccessLevel() == Datasource.AccessLevel.PUBLIC) {
            return true;
        }

        // No certificates required
        if (!datasource.getRequiresCertificate() || datasource.getRequiredCertificateTypes().isEmpty()) {
            return true;
        }

        // Check if user has one of the required certificates
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