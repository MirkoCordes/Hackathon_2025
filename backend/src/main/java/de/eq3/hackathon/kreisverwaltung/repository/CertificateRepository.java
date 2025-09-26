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

    // Alle Zertifikate eines Users
    List<Certificate> findByUser(User user);

    // Aktive Zertifikate eines Users
    List<Certificate> findByUserAndStatus(User user, Certificate.Status status);

    // Alle Zertifikate die Überprüfung brauchen
    List<Certificate> findByStatusIn(List<Certificate.Status> statuses);

    // Zertifikate die bald ablaufen (nächste 30 Tage)
    @Query("SELECT c FROM Certificate c WHERE c.validUntil BETWEEN :now AND :thirtyDaysFromNow AND c.status = :approved")
    List<Certificate> findExpiringSoon(LocalDateTime now, LocalDateTime thirtyDaysFromNow, Certificate.Status approved);

    // Abgelaufene Zertifikate
    @Query("SELECT c FROM Certificate c WHERE c.validUntil < :now AND c.status = :approved")
    List<Certificate> findExpired(LocalDateTime now, Certificate.Status approved);

    // Zertifikate nach Typ für einen User
    List<Certificate> findByUserAndTypeAndStatus(User user, Certificate.CertificateType type,
            Certificate.Status status);
}