import 'package:flutter_frontend/feature/my_data_requests/my_data_requests.model.dart';
import 'package:flutter_frontend/feature/my_data_requests/my_data_requests.repository.dart';
import 'package:flutter_frontend/feature/marketplace/data_request_response.model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'my_data_requests.controller.g.dart';

@riverpod
class MyDataRequestsController extends _$MyDataRequestsController {
  @override
  Future<MyDataRequestsModel> build() {
    final MyDataRequestsRepository repository = MyDataRequestsRepository();
    return repository.getMyRequests();
  }

  /// Refresh the list of my data requests
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() {
      final MyDataRequestsRepository repository = MyDataRequestsRepository();
      return repository.getMyRequests();
    });
  }

  /// Close a data request with a specific status and reason
  Future<void> closeRequest(int requestId, String status, String? reason) async {
    final MyDataRequestsRepository repository = MyDataRequestsRepository();

    await repository.closeRequest(requestId, status, reason);

    // Refresh the list after closing
    await refresh();
  }

  /// Accept a response to a data request
  Future<void> acceptResponse(int responseId) async {
    final MyDataRequestsRepository repository = MyDataRequestsRepository();

    await repository.acceptResponse(responseId);

    // Refresh the list after accepting
    await refresh();
  }

  /// Get responses for a specific request
  Future<List<DataRequestResponseModel>> getResponsesForRequest(int requestId) async {
    final MyDataRequestsRepository repository = MyDataRequestsRepository();
    return repository.getResponsesForRequest(requestId);
  }
}
