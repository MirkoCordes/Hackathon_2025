// ignore_for_file: unused_import

import 'dart:convert';

import 'package:flutter_frontend/feature/catalog/dataset.dart';
import 'package:flutter_frontend/feature/marketplace/data_request.model.dart';
import 'package:flutter_frontend/feature/marketplace/data_requests.model.dart';
import 'package:flutter_frontend/feature/marketplace/data_request_response.model.dart';
import 'package:flutter_frontend/jwt.repository.dart';
import 'package:http/http.dart' as http;

class DataRequestsRepository {
  static const String url = 'http://localhost:8080/api/data-marketplace';

  /// Like a data request
  Future<void> likeRequest(int requestId) async {
    final String? jwt = await JwtRepository().getJwt();
    if (jwt == null) {
      throw Exception('Authentication required');
    }

    final response = await http.post(
      Uri.parse('$url/requests/$requestId/like'),
      headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to like request');
    }
  }

  /// Creates a new data request
  Future<DataRequestModel> createDataRequest(DataRequestModel dataRequest) async {
    final String? jwt = await JwtRepository().getJwt();
    if (jwt == null) {
      throw Exception('Authentication required');
    }

    // Use the toJson method of the DataRequestModel to build the request body
    final Map<String, dynamic> requestBody = dataRequest.toJson();

    // Remove fields that shouldn't be sent to the server (auto-generated/managed by backend)
    requestBody.remove('id');
    requestBody.remove('createdAt');
    requestBody.remove('lastUpdated');
    requestBody.remove('closedAt');
    requestBody.remove('closedReason');
    requestBody.remove('open');
    requestBody.remove('activeResponseIds');
    requestBody.remove('responseCount');
    requestBody.remove('formattedAge');
    requestBody.remove('responseIds');
    requestBody.remove('userId');

    final response = await http.post(
      Uri.parse('$url/requests'),
      headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      final String utf8Decoded = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> jsonMap = json.decode(utf8Decoded);
      return DataRequestModel.fromJson(jsonMap);
    } else if (response.statusCode == 400) {
      final String errorBody = utf8.decode(response.bodyBytes);
      throw Exception('Bad request: $errorBody');
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized - please log in again');
    } else if (response.statusCode == 403) {
      throw Exception('Forbidden');
    }
    throw Exception('Failed to create data request: ${response.statusCode} - ${response.body}');
  }

  /// Creates a new response to a data request
  Future<DataRequestResponseModel> createResponse(
    int requestId,
    DataRequestResponseModel responseModel,
  ) async {
    final String? jwt = await JwtRepository().getJwt();
    if (jwt == null) {
      throw Exception('Authentication required');
    }

    // Use the toJson method of the DataRequestResponseModel to build the request body
    final Map<String, dynamic> requestBody = responseModel.toJson();

    // Remove fields that shouldn't be sent to the server (auto-generated/managed by backend)
    requestBody.remove('id');
    requestBody.remove('createdAt');
    requestBody.remove('lastUpdated');
    requestBody.remove('formattedAge');
    requestBody.remove('pending');
    requestBody.remove('accepted');

    final httpResponse = await http.post(
      Uri.parse('$url/requests/$requestId/responses'),
      headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );

    if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) {
      final String utf8Decoded = utf8.decode(httpResponse.bodyBytes);
      final Map<String, dynamic> jsonMap = json.decode(utf8Decoded);
      return DataRequestResponseModel.fromJson(jsonMap);
    } else if (httpResponse.statusCode == 400) {
      final String errorBody = utf8.decode(httpResponse.bodyBytes);
      throw Exception('Bad request: $errorBody');
    } else if (httpResponse.statusCode == 401) {
      throw Exception('Unauthorized - please log in again');
    } else if (httpResponse.statusCode == 403) {
      throw Exception('Forbidden');
    } else if (httpResponse.statusCode == 404) {
      throw Exception('Data request not found');
    }
    throw Exception('Failed to create response: ${httpResponse.statusCode} - ${httpResponse.body}');
  }

  Future<DataRequestsModel> get(
    String status,
    String? category,
    String? query,
  ) async {
    final String? jwt = await JwtRepository().getJwt();
    if (jwt == null) {
      return Future.error('failed loading dataset');
    }

    final Map<String, dynamic> queryParameter = {};

    if (query != null) {
      queryParameter['search'] = query;
    }

    if (category != null) {
      queryParameter['category'] = category;
    }

    queryParameter['status'] = status;

    final response = await http.get(
      Uri.http('localhost:8080', '/api/data-marketplace', queryParameter),
      headers: {
        'Authorization': 'Bearer $jwt',
      },
    );

    if (response.statusCode == 200) {
      final String utf8Decodes = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> jsonMap = json.decode(utf8Decodes);
      return DataRequestsModel.fromJson(jsonMap);
    } else if (response.statusCode == 403) {
      throw Exception('Unauthorized');
    } else {
      throw Exception('any other error');
    }
  }
}
