package de.eq3.hackathon.kreisverwaltung.repository;

import de.eq3.hackathon.kreisverwaltung.entity.DataAccessRequest;
import de.eq3.hackathon.kreisverwaltung.entity.Datasource;
import de.eq3.hackathon.kreisverwaltung.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DataAccessRequestRepository extends JpaRepository<DataAccessRequest, Long> {

    List<DataAccessRequest> findByUser(User user);

    List<DataAccessRequest> findByDatasource(Datasource datasource);

    List<DataAccessRequest> findByStatus(DataAccessRequest.Status status);

    List<DataAccessRequest> findByUserAndDatasource(User user, Datasource datasource);

    @Query("SELECT dar FROM DataAccessRequest dar WHERE dar.status IN (:statuses)")
    List<DataAccessRequest> findByStatuses(List<DataAccessRequest.Status> statuses);

    boolean existsByUserAndDatasourceAndStatusIn(User user, Datasource datasource,
            List<DataAccessRequest.Status> statuses);
}