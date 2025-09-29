import 'dart:convert';

import 'package:flutter_frontend/feature/login/login_response.model.dart';
import 'package:http/http.dart' as http;

class LoginRepository {
  static const String url = "http://localhost:8080/api/auth/login";

  String getJwt() {
    return 'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhZG1pbiIsImlhdCI6MTc1ODg3ODExMSwiZXhwIjoxNzU4OTY0NTExfQ.SBsI-H3oZHu79t7_AbnmLvWAskyFOJt2zWd5mqLDw3M';
  }

  void setJwt(String jwt) {}

  Future<LoginResponse> login(String username, String pw) async {
    final Map<String, dynamic> loginPayload = {
      'username': username,
      'password': pw,
    };
    final response = await http.post(
      Uri.parse(url),
      body: jsonEncode(loginPayload),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      // Login erfolgreich, der Server gibt die Benutzerdaten zurück

      // JSON-String in eine Dart-Map umwandeln
      final Map<String, dynamic> jsonMap = json.decode(response.body);

      // Deserialisierung: JSON-Map in Ihr User-Modell umwandeln
      return LoginResponse.fromJson(jsonMap);
    } else if (response.statusCode == 403) {
      // 401: Unauthorized (typisch für ungültige Anmeldedaten)
      throw Exception('Ungültiger Benutzername oder Passwort.');
    } else {
      // Andere Fehler wie 500 Server Error
      throw Exception(
        'Login fehlgeschlagen. Statuscode: ${response.statusCode}',
      );
    }
  }

  void register(String username, String pw, String email) {}
}
