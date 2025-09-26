package de.eq3.hackathon.kreisverwaltung.dto;

import lombok.Data;

@Data
public class DataAccessRequestDto {
    private Long datasourceId;
    private Long certificateId;
    private String requestReason;
    private String intendedUse;
}