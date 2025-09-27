import 'package:flutter_frontend/feature/marketplace/data_request.model.dart';
import 'package:flutter_frontend/feature/marketplace/data_requests.model.dart';
import 'package:flutter_frontend/feature/marketplace/data_request_response.model.dart';
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

  /// Creates a response to a data request
  Future<DataRequestResponseModel> createResponse(
    int requestId,
    DataRequestResponseModel responseModel,
  ) async {
    final DataRequestsRepository repository = DataRequestsRepository();

    // Create the response and return the result
    // Any exceptions from the repository will be automatically propagated to the UI
    final createdResponse = await repository.createResponse(requestId, responseModel);

    // Optionally refresh the data requests list to show updated response counts
    // Note: We don't update the main state here as responses are typically handled
    // in a separate part of the UI, but we could refresh if needed

    return createdResponse;
  }
}
