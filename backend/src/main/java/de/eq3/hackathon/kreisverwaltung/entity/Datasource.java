package de.eq3.hackathon.kreisverwaltung.entity;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.ToString;

@Entity
@Table(name = "datasources")
@Data
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(exclude = { "accessRequests" })
@ToString(exclude = { "accessRequests" })
public class Datasource {
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	// === REQUIRED ATTRIBUTES ===
	@Column(nullable = false)
	private String title; // Data source name

	@Column(length = 2000)
	private String description; // Detailed description

	@Enumerated(EnumType.STRING)
	@Column(nullable = false)
	private Category category; // Government, Business, Science, Civil Society

	@Enumerated(EnumType.STRING)
	@Column(nullable = false)
	private DataFormat dataFormat; // CSV, JSON, API, Database, etc.

	@Enumerated(EnumType.STRING)
	@Column(nullable = false)
	private AccessLevel accessLevel; // PUBLIC, RESTRICTED, PRIVATE

	// === CONTACT & ACCESS ===
	@Column(nullable = false)
	private String contactEmail; // Contact person

	@Column
	private String contactName; // Contact person name

	@Column
	private String organization; // Organization/Authority

	@Column
	private String dataUrl; // URL to data source or API

	@Column
	private String documentationUrl; // Link to documentation

	// === CERTIFICATES & SECURITY ===
	@Column(nullable = false)
	private Boolean requiresCertificate = false; // Requires certificate for access

	// Required certificate types - simple like tags!
	@ElementCollection(targetClass = Certificate.CertificateType.class, fetch = FetchType.EAGER)
	@Enumerated(EnumType.STRING)
	@CollectionTable(name = "datasource_required_certificates", joinColumns = @JoinColumn(name = "datasource_id"))
	@Column(name = "certificate_type")
	private List<Certificate.CertificateType> requiredCertificateTypes = new ArrayList<>();

	@Column
	private String certificateRequirements; // Description of which certificates are required

	@Enumerated(EnumType.STRING)
	@Column
	private DataSensitivity dataSensitivity; // Data sensitivity level

	// === RELATIONSHIPS ===
	// Relationships to Access Requests
	@OneToMany(mappedBy = "datasource", fetch = FetchType.LAZY)
	@JsonManagedReference("datasource-accessrequests")
	private List<DataAccessRequest> accessRequests = new ArrayList<>();

	// === METADATA ===
	@Column
	private LocalDateTime lastUpdated; // Last update timestamp

	@Column
	private LocalDateTime createdAt; // Creation timestamp

	@Column
	private String updateFrequency; // Update frequency (daily, weekly, etc.)

	@Column
	private String licenseType; // License type (CC0, CC-BY, proprietary, etc.)

	@Column
	private Long estimatedSize; // Estimated size in bytes

	// === FLEXIBLE TAGS ===
	@ElementCollection
	@CollectionTable(name = "datasource_tags", joinColumns = @JoinColumn(name = "datasource_id"))
	@Column(name = "tag")
	private List<String> tags = new ArrayList<>();

	// === ADDITIONAL FREE METADATA ===
	@ElementCollection
	@CollectionTable(name = "datasource_metadata", joinColumns = @JoinColumn(name = "datasource_id"))
	@MapKeyColumn(name = "metadata_key")
	@Column(name = "metadata_value", length = 1000)
	private Map<String, String> additionalMetadata = new HashMap<>();

	// === ENUMS ===
	public enum Category {
		GOVERNMENT("Verwaltung"),
		BUSINESS("Wirtschaft"),
		SCIENCE("Wissenschaft"),
		CIVIL_SOCIETY("Zivilgesellschaft");

		private final String displayName;

		Category(String displayName) {
			this.displayName = displayName;
		}

		public String getDisplayName() {
			return displayName;
		}
	}

	public enum DataFormat {
		CSV("CSV-Datei"),
		JSON("JSON-Datei"),
		XML("XML-Datei"),
		REST_API("REST API"),
		SOAP_API("SOAP API"),
		DATABASE("Datenbank"),
		EXCEL("Excel-Datei"),
		PDF("PDF-Dokument"),
		SHAPEFILE("Shapefile (GIS)"),
		WMS("Web Map Service"),
		WFS("Web Feature Service"),
		OTHER("Sonstiges");

		private final String displayName;

		DataFormat(String displayName) {
			this.displayName = displayName;
		}

		public String getDisplayName() {
			return displayName;
		}
	}

	public enum AccessLevel {
		PUBLIC("Öffentlich"),
		RESTRICTED("Eingeschränkt"),
		PRIVATE("Privat/Vertraulich");

		private final String displayName;

		AccessLevel(String displayName) {
			this.displayName = displayName;
		}

		public String getDisplayName() {
			return displayName;
		}
	}

	public enum DataSensitivity {
		PUBLIC("Öffentlich", "Keine besonderen Zugangsbeschränkungen"),
		INTERNAL("Intern", "Nur für interne Zwecke, einfache Registrierung"),
		CONFIDENTIAL("Vertraulich", "Professioneller Nachweis erforderlich"),
		RESTRICTED("Beschränkt", "Behördliche/Forschungs-Zertifikate erforderlich"),
		CLASSIFIED("Geheim", "Höchste Sicherheitsstufe, spezielle Berechtigung");

		private final String displayName;
		private final String description;

		DataSensitivity(String displayName, String description) {
			this.displayName = displayName;
			this.description = description;
		}

		public String getDisplayName() {
			return displayName;
		}

		public String getDescription() {
			return description;
		}
	}

	// === LIFECYCLE METHODS ===
	@PrePersist
	protected void onCreate() {
		createdAt = LocalDateTime.now();
		lastUpdated = LocalDateTime.now();
	}

	@PreUpdate
	protected void onUpdate() {
		lastUpdated = LocalDateTime.now();
	}
}