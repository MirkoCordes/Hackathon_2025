package de.eq3.hackathon.kreisverwaltung.controller;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
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
import de.eq3.hackathon.kreisverwaltung.entity.User;
import de.eq3.hackathon.kreisverwaltung.service.DatasourceService;
import de.eq3.hackathon.kreisverwaltung.service.UserService;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/datasources")
@RequiredArgsConstructor
public class DatasourceController {

	private final DatasourceService datasourceService;
	private final UserService userService;

	@GetMapping
	public ResponseEntity<List<Datasource>> getAllDatasources(
			@RequestParam(required = false) String title,
			@RequestParam(required = false) String description,
			@RequestParam(required = false) Datasource.Category category,
			@RequestParam(required = false) Datasource.AccessLevel accessLevel,
			@RequestParam(required = false) Datasource.DataFormat dataFormat,
			@RequestParam(required = false) Boolean requiresCertificate,
			@RequestParam(required = false) String tags,
			@RequestParam(required = false, defaultValue = "false") Boolean onlyAccessible) {

		Authentication auth = SecurityContextHolder.getContext().getAuthentication();

		List<Datasource> datasources;

		// Apply filtering
		if (tags != null && !tags.isEmpty()) {
			List<String> tagList = Arrays.asList(tags.split(","));
			datasources = datasourceService.getDatasourcesByTags(tagList);
		} else if (hasAnyFilterParameter(title, description, category, accessLevel, dataFormat, requiresCertificate)) {
			datasources = datasourceService.searchDatasources(title, description, category, accessLevel, dataFormat,
					requiresCertificate);
		} else {
			datasources = datasourceService.getAllDatasources();
		}

		// Show only accessible datasources (if desired)
		if (onlyAccessible && auth != null && auth.isAuthenticated()) {
			User currentUser = userService.findByUsername(auth.getName()).orElse(null);
			if (currentUser != null) {
				datasources = datasources.stream()
						.filter(currentUser::canAccessDatasource)
						.collect(Collectors.toList());
			}
		}

		return ResponseEntity.ok(datasources);
	}

	@GetMapping("/{id}")
	public ResponseEntity<Datasource> getDatasourceById(@PathVariable Long id) {
		Optional<Datasource> datasource = datasourceService.getDatasourceById(id);
		return datasource.map(ResponseEntity::ok)
				.orElse(ResponseEntity.notFound().build());
	}

	@PostMapping
	@PreAuthorize("hasRole('DATA_PROVIDER') or hasRole('ADMIN')")
	public ResponseEntity<Datasource> createDatasource(@RequestBody Datasource datasource) {
		Datasource saved = datasourceService.saveDatasource(datasource);
		return ResponseEntity.ok(saved);
	}

	@PutMapping("/{id}")
	@PreAuthorize("hasRole('DATA_PROVIDER') or hasRole('ADMIN')")
	public ResponseEntity<Datasource> updateDatasource(@PathVariable Long id,
			@RequestBody Datasource datasource) {
		if (!datasourceService.getDatasourceById(id).isPresent()) {
			return ResponseEntity.notFound().build();
		}

		datasource.setId(id);
		Datasource updated = datasourceService.saveDatasource(datasource);
		return ResponseEntity.ok(updated);
	}

	@DeleteMapping("/{id}")
	@PreAuthorize("hasRole('ADMIN')")
	public ResponseEntity<Void> deleteDatasource(@PathVariable Long id) {
		if (!datasourceService.getDatasourceById(id).isPresent()) {
			return ResponseEntity.notFound().build();
		}

		datasourceService.deleteDatasource(id);
		return ResponseEntity.noContent().build();
	}

	@GetMapping("/categories")
	public ResponseEntity<Datasource.Category[]> getCategories() {
		return ResponseEntity.ok(Datasource.Category.values());
	}

	@GetMapping("/access-levels")
	public ResponseEntity<Datasource.AccessLevel[]> getAccessLevels() {
		return ResponseEntity.ok(Datasource.AccessLevel.values());
	}

	@GetMapping("/data-formats")
	public ResponseEntity<Datasource.DataFormat[]> getDataFormats() {
		return ResponseEntity.ok(Datasource.DataFormat.values());
	}

	@GetMapping("/my-accessible")
	@PreAuthorize("isAuthenticated()")
	public ResponseEntity<List<Datasource>> getMyAccessibleDatasources() {
		Authentication auth = SecurityContextHolder.getContext().getAuthentication();
		User currentUser = userService.findByUsername(auth.getName()).orElse(null);

		if (currentUser == null) {
			return ResponseEntity.status(401).build();
		}

		List<Datasource> accessible = datasourceService.getAccessibleDatasources(currentUser);
		return ResponseEntity.ok(accessible);
	}

	@GetMapping("/{id}/can-access")
	@PreAuthorize("isAuthenticated()")
	public ResponseEntity<Boolean> canAccessDatasource(@PathVariable Long id) {
		Authentication auth = SecurityContextHolder.getContext().getAuthentication();
		User currentUser = userService.findByUsername(auth.getName()).orElse(null);

		if (currentUser == null) {
			return ResponseEntity.status(401).build();
		}

		boolean canAccess = datasourceService.canUserAccessDatasource(currentUser, id);
		return ResponseEntity.ok(canAccess);
	}

	private boolean hasAnyFilterParameter(String title, String description,
			Datasource.Category category,
			Datasource.AccessLevel accessLevel,
			Datasource.DataFormat dataFormat,
			Boolean requiresCertificate) {
		return title != null || description != null || category != null ||
				accessLevel != null || dataFormat != null || requiresCertificate != null;
	}
}