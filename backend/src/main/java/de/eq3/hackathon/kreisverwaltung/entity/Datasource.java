package de.eq3.hackathon.kreisverwaltung.entity;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "datasources")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Datasource {
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	// === PFLICHT-ATTRIBUTE ===
	@Column(nullable = false)
	private String title; // Name der Datenquelle

	@Column(length = 2000)
	private String description; // Beschreibung

	@Enumerated(EnumType.STRING)
	@Column(nullable = false)
	private Category category; // Verwaltung, Wirtschaft, Wissenschaft, Zivilgesellschaft

	@Enumerated(EnumType.STRING)
	@Column(nullable = false)
	private DataFormat dataFormat; // CSV, JSON, API, Database, etc.

	@Enumerated(EnumType.STRING)
	@Column(nullable = false)
	private AccessLevel accessLevel; // PUBLIC, RESTRICTED, PRIVATE

	// === KONTAKT & ZUGANG ===
	@Column(nullable = false)
	private String contactEmail; // Ansprechpartner

	@Column
	private String contactName; // Name des Ansprechpartners

	@Column
	private String organization; // Organisation/Behörde

	@Column
	private String dataUrl; // URL zur Datenquelle oder API

	@Column
	private String documentationUrl; // Link zur Dokumentation

	// === ZERTIFIKATE & SICHERHEIT ===
	@Column(nullable = false)
	private Boolean requiresCertificate = false; // Braucht Zertifikat für Zugang

	@Column
	private String certificateRequirements; // Welche Art von Zertifikat

	// === METADATEN ===
	@Column
	private LocalDateTime lastUpdated; // Letzte Aktualisierung

	@Column
	private LocalDateTime createdAt; // Erstellungsdatum

	@Column
	private String updateFrequency; // Wie oft wird aktualisiert (täglich, wöchentlich, etc.)

	@Column
	private String licenseType; // Lizenz (CC0, CC-BY, proprietary, etc.)

	@Column
	private Long estimatedSize; // Geschätzte Größe in Bytes

	// === FLEXIBLE TAGS ===
	@ElementCollection
	@CollectionTable(name = "datasource_tags", joinColumns = @JoinColumn(name = "datasource_id"))
	@Column(name = "tag")
	private List<String> tags = new ArrayList<>();

	// === ZUSÄTZLICHE FREIE METADATEN ===
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