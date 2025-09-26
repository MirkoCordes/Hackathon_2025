import 'package:flutter_frontend/jwt.repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'logout.controller.g.dart';



@riverpod
class LogoutController extends _$LogoutController{
  /// Die 'build'-Methode muss den initialen Zustand des Providers zurückgeben.
  @override
  void build() {}

  Future<void> logout() async {
    final JwtRepository jwtRepository = JwtRepository();
    await jwtRepository.clear();
  }

}