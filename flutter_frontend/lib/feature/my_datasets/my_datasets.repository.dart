// ignore_for_file: unused_import

import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_frontend/feature/catalog/catalog_response.model.dart';
import 'package:flutter_frontend/feature/catalog/dataset.dart';
import 'package:flutter_frontend/feature/marketplace/data_request.model.dart';
import 'package:flutter_frontend/feature/marketplace/data_requests.model.dart';
import 'package:flutter_frontend/jwt.repository.dart';
import 'package:http/http.dart' as http;

class MyDatasetsRepository {
  Future<CatalogResponse> get() async {
    final String? jwt = await JwtRepository().getJwt();
    if (jwt == null) {
      return Future.error('failed loading dataset');
    }

    final response = await http.get(
      Uri.http('localhost:8080', '/api/datasources/my'),
      headers: {
        'Authorization': 'Bearer $jwt',
      },
    );

    if (response.statusCode == 200) {
      final String utf8Decodes = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> jsonMap = json.decode(utf8Decodes);
      return CatalogResponse.fromJson(jsonMap);
    } else if (response.statusCode == 403) {
      throw Exception('Unauthorized');
    } else {
      throw Exception('any other error');
    }
  }

  Future<CatalogResponse> create(Dataset dataset) async {
    final String? jwt = await JwtRepository().getJwt();
    if (jwt == null) {
      return Future.error('failed loading dataset');
    }

    // Dataset in Map konvertieren
    final Map<String, dynamic> jsonMap = dataset.toJson();

    // 'id' entfernen
    jsonMap.remove('id');

    final String json = jsonEncode(jsonMap);

    debugPrint(json);

    final response = await http.post(
      Uri.http('localhost:8080', '/api/datasources'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
      body: json,
    );

    if (response.statusCode == 200) {
      final String utf8Decodes = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> jsonMap = jsonDecode(utf8Decodes);
      return CatalogResponse.fromJson(jsonMap);
    } else if (response.statusCode == 403) {
      throw Exception('Unauthorized');
    } else {
      throw Exception('any other error');
    }
  }
}
