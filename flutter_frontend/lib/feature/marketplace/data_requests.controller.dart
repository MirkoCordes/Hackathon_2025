import 'package:flutter_frontend/feature/marketplace/data_requests.model.dart';
import 'package:flutter_frontend/feature/marketplace/data_requests.repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'data_requests.controller.g.dart';

@riverpod
class DataRequestsController extends _$DataRequestsController {
  @override
  Future<DataRequestsModel> build() {
    final DataRequestsRepository repository = DataRequestsRepository();
    return repository.get('OPEN', null, null);
  }
}
