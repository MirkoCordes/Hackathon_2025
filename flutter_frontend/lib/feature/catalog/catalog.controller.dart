import 'package:flutter_frontend/feature/catalog/catalog.repository.dart';
import 'package:flutter_frontend/feature/catalog/catalog.state.dart';
import 'package:flutter_frontend/feature/catalog/catalog_response.model.dart';
import 'package:flutter_frontend/feature/catalog/dataset.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'catalog.controller.g.dart';

@riverpod
class CatalogController extends _$CatalogController {
  /// Die 'build'-Methode muss den initialen Zustand des Providers zurückgeben.
  @override
  CatalogState build() {
    return CatalogState(searchQuery: '', datasets: List.empty());
  }

  Future<void> search({
    required String query,
    Category? category,
    DataFormat? dataFormat,
    AccessLevel? accessLevel,
    DataSensitivity? dataSensitivity,
  }) async {
    final CatalogRepository catalogRepository = CatalogRepository();
    final CatalogResponse response = await catalogRepository.getCatalogs(
      query: query,
      category: category,
      dataFormat: dataFormat,
      accessLevel: accessLevel,
      dataSensitivity: dataSensitivity,
    );
    state = CatalogState(searchQuery: query, datasets: response.datasources);
  }

  Future<void> updateFilterList() async {}
}
