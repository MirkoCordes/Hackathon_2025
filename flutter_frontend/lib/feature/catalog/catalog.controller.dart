import 'package:flutter_frontend/feature/catalog/catalog.state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'catalog.controller.g.dart';

@riverpod
class CatalogController extends _$CatalogController {
  /// Die 'build'-Methode muss den initialen Zustand des Providers zurückgeben.
  @override
  CatalogState build() {
    return CatalogState(searchQuery: '');
  }

  void search(String query) {}
}
