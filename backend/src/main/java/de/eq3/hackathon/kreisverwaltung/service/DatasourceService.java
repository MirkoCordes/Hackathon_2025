package de.eq3.hackathon.kreisverwaltung.service;

import de.eq3.hackathon.kreisverwaltung.entity.Datasource;
import de.eq3.hackathon.kreisverwaltung.entity.User;
import de.eq3.hackathon.kreisverwaltung.repository.DatasourceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class DatasourceService {

    private final DatasourceRepository datasourceRepository;

    public List<Datasource> getAllDatasources() {
        return datasourceRepository.findAll();
    }

    public Optional<Datasource> getDatasourceById(Long id) {
        return datasourceRepository.findById(id);
    }

    public Datasource saveDatasource(Datasource datasource) {
        return datasourceRepository.save(datasource);
    }

    public void deleteDatasource(Long id) {
        datasourceRepository.deleteById(id);
    }

    // Search and filtering
    public List<Datasource> searchDatasources(String title, String description,
            Datasource.Category category,
            Datasource.AccessLevel accessLevel,
            Datasource.DataFormat dataFormat,
            Boolean requiresCertificate) {
        return datasourceRepository.findByFilters(title, description, category,
                accessLevel, dataFormat, requiresCertificate);
    }

    public List<Datasource> getDatasourcesByCategory(Datasource.Category category) {
        return datasourceRepository.findByCategory(category);
    }

    public List<Datasource> getDatasourcesByTags(List<String> tags) {
        return datasourceRepository.findByTagsIn(tags);
    }

    // Check access permissions
    public List<Datasource> getAccessibleDatasources(User user) {
        return getAllDatasources().stream()
                .filter(user::canAccessDatasource)
                .toList();
    }

    public boolean canUserAccessDatasource(User user, Long datasourceId) {
        Optional<Datasource> datasource = getDatasourceById(datasourceId);
        return datasource.map(user::canAccessDatasource).orElse(false);
    }
}