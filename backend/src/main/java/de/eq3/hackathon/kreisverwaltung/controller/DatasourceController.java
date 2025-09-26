package de.eq3.hackathon.kreisverwaltung.controller;

import java.util.ArrayList;
import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import de.eq3.hackathon.kreisverwaltung.entity.Datasource;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/datasources")
@RequiredArgsConstructor
public class DatasourceController {

	@GetMapping
	@PreAuthorize("isAuthenticated()")
	public ResponseEntity<List<Datasource>> search(@RequestParam(value = "q", required = false) String query) {
		return ResponseEntity.ok(new ArrayList<>());
	}

	@PutMapping
	@PreAuthorize("hasRole('ADMIN')")
	public ResponseEntity<Datasource> create(@Validated @RequestBody Datasource request,
			Authentication authentication) {
		Datasource created = new Datasource();
		return ResponseEntity.status(HttpStatus.CREATED).body(created);
	}

	@PostMapping("/{id}")
	@PreAuthorize("hasRole('ADMIN')")
	public ResponseEntity<Datasource> update(@PathVariable Long id, @Validated @RequestBody Datasource request,
			Authentication authentication) {
		Datasource updated = new Datasource();
		return ResponseEntity.ok(updated);
	}

	@DeleteMapping("/{id}")
	@PreAuthorize("hasRole('ADMIN')")
	public ResponseEntity<Void> delete(@PathVariable Long id) {
		return ResponseEntity.noContent().build();
	}
}