import 'package:flutter_frontend/feature/login/login.repository.dart';
import 'package:flutter_frontend/feature/login/login_response.model.dart';
import 'package:flutter_frontend/jwt.repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'login.controller.g.dart';

@riverpod
class LoginController extends _$LoginController {
  /// Die 'build'-Methode muss den initialen Zustand des Providers zurückgeben.
  @override
  void build() {}

  Future<void> login(String username, String pw) async {
    final LoginRepository loginRepository = LoginRepository();
    final LoginResponse response = await loginRepository.login(username, pw);
    final JwtRepository jwtRepository = JwtRepository();
    await jwtRepository.setJwt(response.token);
    await jwtRepository.setRole(response.role);
  }
}
