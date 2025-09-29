import 'dart:convert';
import 'package:flutter_frontend/feature/my_data_requests/my_data_requests.model.dart';
import 'package:flutter_frontend/feature/marketplace/data_request_response.model.dart';
import 'package:flutter_frontend/jwt.repository.dart';
import 'package:http/http.dart' as http;

class MyDataRequestsRepository {
  static const String url = 'http://localhost:8080/api/data-marketplace';

  /// Fetches all data requests created by the current user
  Future<MyDataRequestsModel> getMyRequests() async {
    final String? jwt = await JwtRepository().getJwt();
    if (jwt == null) {
      throw Exception('Authentication required');
    }

    final response = await http.get(
      Uri.parse('$url/my-requests'),
      headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final String utf8Decoded = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> jsonMap = json.decode(utf8Decoded);
      return MyDataRequestsModel.fromJson(jsonMap);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized - please log in again');
    } else if (response.statusCode == 403) {
      throw Exception('Forbidden');
    }
    throw Exception('Failed to load my requests: ${response.statusCode} - ${response.body}');
  }

  /// Fetches all responses for a specific data request
  Future<List<DataRequestResponseModel>> getResponsesForRequest(int requestId) async {
    final String? jwt = await JwtRepository().getJwt();
    if (jwt == null) {
      throw Exception('Authentication required');
    }

    final response = await http.get(
      Uri.parse('$url/requests/$requestId/responses'),
      headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final String utf8Decoded = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> jsonMap = json.decode(utf8Decoded);
      return (jsonMap['responses'] as List<dynamic>).map((json) => DataRequestResponseModel.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized - please log in again');
    } else if (response.statusCode == 404) {
      throw Exception('Request not found');
    }
    throw Exception('Failed to load responses: ${response.statusCode} - ${response.body}');
  }

  /// Closes a data request with a specific status and reason
  Future<void> closeRequest(int requestId, String status, String? reason) async {
    final String? jwt = await JwtRepository().getJwt();
    if (jwt == null) {
      throw Exception('Authentication required');
    }

    final Map<String, String> queryParams = {'status': status};
    if (reason != null && reason.isNotEmpty) {
      queryParams['reason'] = reason;
    }

    final response = await http.post(
      Uri.parse('$url/requests/$requestId/close').replace(queryParameters: queryParams),
      headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized - please log in again');
    } else if (response.statusCode == 403) {
      throw Exception('Forbidden - you can only close your own requests');
    } else if (response.statusCode == 404) {
      throw Exception('Request not found');
    }
    throw Exception('Failed to close request: ${response.statusCode} - ${response.body}');
  }

  /// Accepts a response to a data request
  Future<void> acceptResponse(int responseId) async {
    final String? jwt = await JwtRepository().getJwt();
    if (jwt == null) {
      throw Exception('Authentication required');
    }

    final response = await http.post(
      Uri.parse('$url/responses/$responseId/accept'),
      headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized - please log in again');
    } else if (response.statusCode == 403) {
      throw Exception('Forbidden - you can only accept responses to your own requests');
    } else if (response.statusCode == 404) {
      throw Exception('Response not found');
    }
    throw Exception('Failed to accept response: ${response.statusCode} - ${response.body}');
  }
}
