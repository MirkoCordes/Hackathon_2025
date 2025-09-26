package de.eq3.hackathon.kreisverwaltung.dto;

import de.eq3.hackathon.kreisverwaltung.entity.Datasource;
import de.eq3.hackathon.kreisverwaltung.entity.DataRequestResponse;
import lombok.Data;

import java.io.Serializable;

@Data
public class DataRequestResponseDto implements Serializable {
    private DataRequestResponse.ResponseType responseType;
    private String message;
    private Long existingDatasourceId; // optional

    // For new datasource proposals
    private String proposedTitle;
    private String proposedDescription;
    private String estimatedDeliveryTime;
    private String estimatedCost;
    private Datasource.DataFormat proposedFormat;
    private Datasource.AccessLevel proposedAccessLevel;

    private String contactEmail;
    private String contactPhone;
}
