import 'package:flutter_frontend/feature/catalog/catalog_response.model.dart';
import 'package:flutter_frontend/feature/catalog/dataset.dart';
import 'package:flutter_frontend/feature/my_datasets/my_datasets.repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'my_datasets.controller.g.dart';

@riverpod
class MyDatasetsController extends _$MyDatasetsController {
  @override
  Future<CatalogResponse> build() {
    final MyDatasetsRepository repository = MyDatasetsRepository();
    return repository.get();
  }

  Future<void> create(Dataset dataset) async {
    try {
      final MyDatasetsRepository repository = MyDatasetsRepository();
      await repository.create(dataset);
    } catch (e) {}
  }
}
