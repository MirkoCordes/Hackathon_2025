package de.eq3.hackathon.kreisverwaltung.repository;

import de.eq3.hackathon.kreisverwaltung.entity.Datasource;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.lang.NonNull;

import java.util.List;
import java.util.Optional;

@Repository
public interface DatasourceRepository extends JpaRepository<Datasource, Long> {
    Optional<Datasource> findById(long id);

    @NonNull
    List<Datasource> findAll();
}