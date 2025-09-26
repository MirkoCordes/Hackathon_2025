import 'package:flutter_frontend/feature/catalog/dataset.dart';
import 'package:flutter_frontend/feature/datasource_detail/datasource_detail.repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'datasource_detail.controller.g.dart';

@riverpod
class DatasourceDetailController extends _$DatasourceDetailController {
  @override
  Future<Dataset> build(String id) {
    return DatasourceDetailRepository().get(id);
  }
}
