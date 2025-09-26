import 'package:flutter_frontend/feature/catalog/dataset.dart';

class CatalogState {
  final String searchQuery;
  final List<Dataset> datasets;

  const CatalogState({required this.searchQuery, required this.datasets});
}
