import 'package:flutter_frontend/feature/login/role.enum.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_response.model.g.dart';

@JsonSerializable()
class LoginResponse {
  final String token;
  final String username;
  final Role role;

  const LoginResponse({
    required this.token,
    required this.username,
    required this.role,
  });

  // Factory-Konstruktor, um ein [User]-Objekt aus einer JSON-Map zu erstellen.
  /// Die eigentliche Implementierung wird durch 'user.g.dart' generiert.
  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  /// Methode, um das [User]-Objekt in eine JSON-Map umzuwandeln.
  /// Die eigentliche Implementierung wird durch 'user.g.dart' generiert.
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}


/*
{
    "token": "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhZG1pbiIsImlhdCI6MTc1ODg3ODExMSwiZXhwIjoxNzU4OTY0NTExfQ.SBsI-H3oZHu79t7_AbnmLvWAskyFOJt2zWd5mqLDw3M",
    "username": "admin",
    "role": "ADMIN"
}
*/