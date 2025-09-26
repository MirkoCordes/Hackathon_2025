package de.eq3.hackathon.kreisverwaltung.repository;

import de.eq3.hackathon.kreisverwaltung.entity.DataRequest;
import de.eq3.hackathon.kreisverwaltung.entity.Datasource;
import de.eq3.hackathon.kreisverwaltung.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface DataRequestRepository extends JpaRepository<DataRequest, Long> {

    // Find by status
    List<DataRequest> findByStatus(DataRequest.Status status);

    // Find open requests (status OPEN)
    List<DataRequest> findByStatusOrderByCreatedAtDesc(DataRequest.Status status);

    // Find requests by user
    List<DataRequest> findByUserOrderByCreatedAtDesc(User user);

    // Find requests by category
    List<DataRequest> findByCategoryOrderByCreatedAtDesc(Datasource.Category category);

    // Find requests by priority
    List<DataRequest> findByPriorityOrderByCreatedAtDesc(DataRequest.Priority priority);

    // Find recent requests (last 30 days)
    @Query("SELECT dr FROM DataRequest dr WHERE dr.createdAt >= :since ORDER BY dr.createdAt DESC")
    List<DataRequest> findRecentRequests(@Param("since") LocalDateTime since);

    // Search in title and description
    @Query("SELECT dr FROM DataRequest dr WHERE " +
            "(LOWER(dr.title) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "LOWER(dr.description) LIKE LOWER(CONCAT('%', :keyword, '%'))) AND " +
            "dr.status = :status " +
            "ORDER BY dr.createdAt DESC")
    List<DataRequest> searchByKeywordAndStatus(@Param("keyword") String keyword,
            @Param("status") DataRequest.Status status);

    // Find popular requests (with most responses)
    @Query("SELECT dr FROM DataRequest dr WHERE dr.status = 'OPEN' ORDER BY SIZE(dr.responses) DESC")
    List<DataRequest> findPopularOpenRequests();

    // Find requests without responses
    @Query("SELECT dr FROM DataRequest dr WHERE dr.status = 'OPEN' AND SIZE(dr.responses) = 0 ORDER BY dr.createdAt DESC")
    List<DataRequest> findOpenRequestsWithoutResponses();

    // Count requests by user
    Long countByUser(User user);

    // Count open requests by category
    @Query("SELECT COUNT(dr) FROM DataRequest dr WHERE dr.category = :category AND dr.status = 'OPEN'")
    Long countOpenRequestsByCategory(@Param("category") Datasource.Category category);

    // Find requests by geographic and time scope
    @Query("SELECT dr FROM DataRequest dr WHERE " +
            "(:geographicScope IS NULL OR LOWER(dr.geographicScope) LIKE LOWER(CONCAT('%', :geographicScope, '%'))) AND "
            +
            "(:timeScope IS NULL OR LOWER(dr.timeScope) LIKE LOWER(CONCAT('%', :timeScope, '%'))) AND " +
            "dr.status = 'OPEN' " +
            "ORDER BY dr.createdAt DESC")
    List<DataRequest> findByGeographicAndTimeScope(@Param("geographicScope") String geographicScope,
            @Param("timeScope") String timeScope);
}