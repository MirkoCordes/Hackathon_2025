import 'package:collection/collection.dart';
import 'package:flutter_frontend/feature/login/role.enum.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JwtRepository {
  static String jwtKey = 'jwtKey';
  static String roleKey = 'roleKey';

  Future<void> setJwt(String jwt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(jwtKey, jwt);
  }

  Future<String?> getJwt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(jwtKey);
  }

  Future<Role?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    final String? role = prefs.getString(roleKey);
    return Role.values.firstWhereOrNull((e) => e.name == role);
  }

  Future<void> setRole(Role role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(roleKey, role.name);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

}
