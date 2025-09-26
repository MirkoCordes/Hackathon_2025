package de.eq3.hackathon.kreisverwaltung.dto;

import de.eq3.hackathon.kreisverwaltung.entity.User;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserProfileDto {
    
    private Long id;
    private String username;
    private String email;
    private String firstName;
    private String lastName;
    private String organization;
    private String jobTitle;
    private User.Role role;
    private boolean enabled;
    private int activeCertificatesCount;
    private int totalCertificatesCount;
    private int accessRequestsCount;
    
    public static UserProfileDto fromUser(User user) {
        UserProfileDto dto = new UserProfileDto();
        dto.setId(user.getId());
        dto.setUsername(user.getUsername());
        dto.setEmail(user.getEmail());
        dto.setFirstName(user.getFirstName());
        dto.setLastName(user.getLastName());
        dto.setOrganization(user.getOrganization());
        dto.setJobTitle(user.getJobTitle());
        dto.setRole(user.getRole());
        dto.setEnabled(user.isEnabled());
        
        // Count certificates and access requests
        if (user.getCertificates() != null) {
            dto.setTotalCertificatesCount(user.getCertificates().size());
            dto.setActiveCertificatesCount((int) user.getCertificates().stream()
                    .filter(cert -> cert.isActive())
                    .count());
        }
        
        if (user.getAccessRequests() != null) {
            dto.setAccessRequestsCount(user.getAccessRequests().size());
        }
        
        return dto;
    }
}