import 'dart:convert';

import 'package:flutter_frontend/feature/catalog/catalog_response.model.dart';
import 'package:http/http.dart' as http;

class CatalogRepository {
  static const String url = "http://localhost:8080/api/datasources";

  Future<CatalogResponse> getCatalogs(String query) async {
    final Map<String, String> header = {
      'Content-Type': 'application/json',
      'Authorization':
          'Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhZG1pbiIsImlhdCI6MTc1ODg4OTczOSwiZXhwIjoxNzU4OTc2MTM5fQ.CiGQba2cd2jR09VLGyRhHy1lVXULj2r_iUdOhme-JNQ',
    };

    final Map<String, dynamic> queryParameter = {'title': query};

    final response = await http.get(
      Uri.http('www.myurl.com', '/api/v1/test', queryParameter),
      headers: header,
    );
    if (response.statusCode == 200) {
      // Login erfolgreich, der Server gibt die Benutzerdaten zurück

      // JSON-String in eine Dart-Map umwandeln
      final List<String> responseList = json.decode(response.body);

      // Deserialisierung: JSON-Map in Ihr User-Modell umwandeln
      return CatalogResponse.fromJson(responseList);
    } else if (response.statusCode == 403) {
      // 401: Unauthorized (typisch für ungültige Anmeldedaten)
      throw Exception('Ungültiger Token.');
    } else {
      // Andere Fehler wie 500 Server Error
      throw Exception('fehlgeschlagen. Statuscode: ${response.statusCode}');
    }
  }
}
