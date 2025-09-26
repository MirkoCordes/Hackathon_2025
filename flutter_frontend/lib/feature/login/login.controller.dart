import 'package:flutter_frontend/feature/login/login.repository.dart';
import 'package:flutter_frontend/feature/login/login.state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'login.controller.g.dart';

@riverpod
class LoginController extends _$LoginController {
  /// Die 'build'-Methode muss den initialen Zustand des Providers zurückgeben.
  @override
  Future<LoginState> build() {
    return Future.value(LoginState(jwt: null));
  }

  void login(String username, String pw) {
    LoginRepository loginRepository = LoginRepository();
    loginRepository.login(username, pw);
  }
}
