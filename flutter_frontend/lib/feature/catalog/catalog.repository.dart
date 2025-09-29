import 'dart:convert';

import 'package:flutter_frontend/feature/catalog/catalog_response.model.dart';
import 'package:flutter_frontend/feature/catalog/dataset.dart';
import 'package:flutter_frontend/jwt.repository.dart';
import 'package:http/http.dart' as http;

class CatalogRepository {
  static const String url = "http://localhost:8080/api/datasources";

  Future<CatalogResponse> getCatalogs({
    required String query,
    Category? category,
    DataFormat? dataFormat,
    AccessLevel? accessLevel,
    DataSensitivity? dataSensitivity,
  }) async {
    final String? jwt = await JwtRepository().getJwt();

    if (jwt == null) {
      return Future.error('failed loading dataset');
    }

    final Map<String, String> header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $jwt',
    };

    final Map<String, dynamic> queryParameter = {
      'title': query,
    };

    if (category != null) {
      queryParameter.putIfAbsent(
        'category',
        () => getJsonValueForCategoryEnum(category),
      );
    }
    if (dataFormat != null) {
      queryParameter.putIfAbsent(
        'dataFormat',
        () => getJsonValueForDataFormatEnum(dataFormat),
      );
    }
    if (accessLevel != null) {
      queryParameter.putIfAbsent(
        'accessLevel',
        () => getJsonValueForAccessLevelEnum(accessLevel),
      );
    }
    if (dataSensitivity != null) {
      queryParameter.putIfAbsent(
        'dataSensitivity',
        () => getJsonValueForDataSensitivityEnum(dataSensitivity),
      );
    }

    final response = await http.get(
      Uri.http('localhost:8080', '/api/datasources', queryParameter),
      headers: header,
    );
    if (response.statusCode == 200) {
      // Login erfolgreich, der Server gibt die Benutzerdaten zurück

      // JSON-String in eine Dart-Map umwandeln
      final String utf8Decodes = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> jsonMap = json.decode(utf8Decodes);

      // Deserialisierung: JSON-Map in Ihr User-Modell umwandeln
      return CatalogResponse.fromJson(jsonMap);
    } else if (response.statusCode == 403) {
      // 401: Unauthorized (typisch für ungültige Anmeldedaten)
      throw Exception('Ungültiger Token.');
    } else {
      // Andere Fehler wie 500 Server Error
      throw Exception('fehlgeschlagen. Statuscode: ${response.statusCode}');
    }
  }
}
