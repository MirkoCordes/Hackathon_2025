import 'package:flutter_frontend/feature/marketplace/data_request.model.dart';
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

  Future<void> create(DataRequestModel dataRequest) async {
    try {
      final DataRequestsRepository repository = DataRequestsRepository();
      await repository.createDataRequest(dataRequest);
      // Refresh the list after creating a new data request
      state = AsyncValue.loading();
      state = await AsyncValue.guard(() => repository.get('OPEN', null, null));
    } catch (e) {
      // Handle error if needed
    }
  }

  Future<void> likeRequest(int requestId) async {
    try {
      final DataRequestsRepository repository = DataRequestsRepository();
      await repository.likeRequest(requestId);
      // Refresh the list after liking a request
      state = AsyncValue.loading();
      state = await AsyncValue.guard(() => repository.get('OPEN', null, null));
    } catch (e) {
      // Handle error if needed
    }
  }
}
