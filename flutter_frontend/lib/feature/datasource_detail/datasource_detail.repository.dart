import 'dart:convert';

import 'package:flutter_frontend/feature/catalog/dataset.dart';
import 'package:flutter_frontend/jwt.repository.dart';
import 'package:http/http.dart' as http;

class DatasourceDetailRepository {
  static const String url = 'http://localhost:8080/api/datasources';

  Future<Dataset> get(String id) async {
    final String? jwt = await JwtRepository().getJwt();

    if (jwt == null) {
      return Future.error('failed loading dataset');
    }

    final response = await http.get(
      Uri.parse('$url/$id'),
      headers: {
        'Authorization': 'Bearer $jwt',
      },
    );
    if (response.statusCode == 200) {
      final String utf8Decodes = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> jsonMap = json.decode(utf8Decodes);
      return Dataset.fromJson(jsonMap);
    } else if (response.statusCode == 403) {
      throw Exception('Unauthorized');
    } else {
      throw Exception('any other error');
    }
  }
}
