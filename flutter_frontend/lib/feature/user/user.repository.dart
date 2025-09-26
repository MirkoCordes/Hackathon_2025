import 'dart:convert';

import 'package:flutter_frontend/feature/user/user.entity.dart';
import 'package:flutter_frontend/jwt.repository.dart';
import 'package:http/http.dart' as http;

class UserRepository {
  static const String url = 'http://localhost:8080/api/user';

  Future<User> getCurrent() async {
    final String? jwt = await JwtRepository().getJwt();

    if (jwt == null) {
      return Future.error('no jwt');
    }

    final response = await http.get(
      Uri.parse('$url/current'),
      headers: {
        'Authorization': 'Bearer $jwt',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap = json.decode(response.body);
      return User.fromJson(jsonMap);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else {
      throw Exception('failed to load user');
    }
  }
}
