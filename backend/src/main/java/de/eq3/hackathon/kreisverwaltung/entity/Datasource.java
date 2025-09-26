package de.eq3.hackathon.kreisverwaltung.entity;

import java.util.Map;
import java.util.HashMap;

import jakarta.persistence.Column;
import jakarta.persistence.CollectionTable;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.MapKeyColumn;
import jakarta.persistence.Table;
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

	@ElementCollection
	@CollectionTable(name = "datasource_metadata", joinColumns = @JoinColumn(name = "datasource_id"))
	@MapKeyColumn(name = "metadata_key")
	@Column(name = "metadata_value")
	private Map<String, String> metadata = new HashMap<>();
}