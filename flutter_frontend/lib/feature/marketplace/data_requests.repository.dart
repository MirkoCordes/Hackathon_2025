// ignore_for_file: unused_import

import 'dart:convert';

import 'package:flutter_frontend/feature/catalog/dataset.dart';
import 'package:flutter_frontend/feature/marketplace/data_request.model.dart';
import 'package:flutter_frontend/feature/marketplace/data_requests.model.dart';
import 'package:flutter_frontend/jwt.repository.dart';
import 'package:http/http.dart' as http;

class DataRequestsRepository {
  static const String url = 'http://localhost:8080/api/data-marketplace';

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
