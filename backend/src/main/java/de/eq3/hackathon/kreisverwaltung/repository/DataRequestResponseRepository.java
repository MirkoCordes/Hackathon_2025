package de.eq3.hackathon.kreisverwaltung.repository;

import de.eq3.hackathon.kreisverwaltung.entity.DataRequest;
import de.eq3.hackathon.kreisverwaltung.entity.DataRequestResponse;
import de.eq3.hackathon.kreisverwaltung.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DataRequestResponseRepository extends JpaRepository<DataRequestResponse, Long> {

    // Find responses by data request
    List<DataRequestResponse> findByDataRequestOrderByCreatedAtDesc(DataRequest dataRequest);

    // Find responses by responder/user
    List<DataRequestResponse> findByResponderOrderByCreatedAtDesc(User responder);

    // Find responses by status
    List<DataRequestResponse> findByStatusOrderByCreatedAtDesc(DataRequestResponse.Status status);

    // Find responses by response type
    List<DataRequestResponse> findByResponseTypeOrderByCreatedAtDesc(DataRequestResponse.ResponseType responseType);

    // Find pending responses for a specific data request
    List<DataRequestResponse> findByDataRequestAndStatus(DataRequest dataRequest, DataRequestResponse.Status status);

    // Count responses by data request
    Long countByDataRequest(DataRequest dataRequest);

    // Count responses by responder
    Long countByResponder(User responder);

    // Find responses for data requests owned by a specific user
    @Query("SELECT drr FROM DataRequestResponse drr WHERE drr.dataRequest.user = :user ORDER BY drr.createdAt DESC")
    List<DataRequestResponse> findResponsesForUserRequests(@Param("user") User user);

    // Find active responses (not withdrawn)
    @Query("SELECT drr FROM DataRequestResponse drr WHERE drr.status != 'WITHDRAWN' ORDER BY drr.createdAt DESC")
    List<DataRequestResponse> findActiveResponses();

    // Find responses by data request and response type
    List<DataRequestResponse> findByDataRequestAndResponseType(DataRequest dataRequest,
            DataRequestResponse.ResponseType responseType);

    // Check if user already responded to a data request
    boolean existsByDataRequestAndResponder(DataRequest dataRequest, User responder);

    // Find responses with existing datasource
    @Query("SELECT drr FROM DataRequestResponse drr WHERE drr.existingDatasource IS NOT NULL ORDER BY drr.createdAt DESC")
    List<DataRequestResponse> findResponsesWithExistingDatasource();

    // Find responses proposing new datasources
    @Query("SELECT drr FROM DataRequestResponse drr WHERE drr.responseType = 'NEW_DATASOURCE' AND drr.proposedTitle IS NOT NULL ORDER BY drr.createdAt DESC")
    List<DataRequestResponse> findNewDatasourceProposals();
}