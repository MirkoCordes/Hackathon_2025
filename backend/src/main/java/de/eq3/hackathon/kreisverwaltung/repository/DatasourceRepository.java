package de.eq3.hackathon.kreisverwaltung.repository;

import de.eq3.hackathon.kreisverwaltung.entity.Datasource;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import org.springframework.lang.NonNull;

import java.util.List;
import java.util.Optional;

@Repository
public interface DatasourceRepository extends JpaRepository<Datasource, Long> {
    Optional<Datasource> findById(long id);

    @NonNull
    List<Datasource> findAll();

    // Search and filtering
    List<Datasource> findByTitleContainingIgnoreCase(String title);

    List<Datasource> findByCategory(Datasource.Category category);

    List<Datasource> findByAccessLevel(Datasource.AccessLevel accessLevel);

    List<Datasource> findByDataFormat(Datasource.DataFormat dataFormat);

    List<Datasource> findByRequiresCertificate(Boolean requiresCertificate);

    @Query("SELECT d FROM Datasource d WHERE " +
            "(:title IS NULL OR LOWER(d.title) LIKE LOWER(CONCAT('%', :title, '%'))) AND " +
            "(:description IS NULL OR LOWER(d.description) LIKE LOWER(CONCAT('%', :description, '%'))) AND " +
            "(:category IS NULL OR d.category = :category) AND " +
            "(:accessLevel IS NULL OR d.accessLevel = :accessLevel) AND " +
            "(:dataFormat IS NULL OR d.dataFormat = :dataFormat) AND " +
            "(:requiresCertificate IS NULL OR d.requiresCertificate = :requiresCertificate)")
    List<Datasource> findByFilters(String title, String description,
            Datasource.Category category,
            Datasource.AccessLevel accessLevel,
            Datasource.DataFormat dataFormat,
            Boolean requiresCertificate);

    @Query("SELECT d FROM Datasource d JOIN d.tags t WHERE t IN :tags")
    List<Datasource> findByTagsIn(List<String> tags);
}