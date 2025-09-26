package de.eq3.hackathon.kreisverwaltung.repository;

import de.eq3.hackathon.kreisverwaltung.entity.Certificate;
import de.eq3.hackathon.kreisverwaltung.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface CertificateRepository extends JpaRepository<Certificate, Long> {

    // All certificates of a user
    List<Certificate> findByUser(User user);

    // Active certificates of a user
    List<Certificate> findByUserAndStatus(User user, Certificate.Status status);

    // All certificates that need review
    List<Certificate> findByStatusIn(List<Certificate.Status> statuses);

    // Certificates expiring soon (next 30 days)
    @Query("SELECT c FROM Certificate c WHERE c.validUntil BETWEEN :now AND :thirtyDaysFromNow AND c.status = :approved")
    List<Certificate> findExpiringSoon(LocalDateTime now, LocalDateTime thirtyDaysFromNow, Certificate.Status approved);

    // Expired certificates
    @Query("SELECT c FROM Certificate c WHERE c.validUntil < :now AND c.status = :approved")
    List<Certificate> findExpired(LocalDateTime now, Certificate.Status approved);

    // Certificates by type for a user
    List<Certificate> findByUserAndTypeAndStatus(User user, Certificate.CertificateType type,
            Certificate.Status status);
}