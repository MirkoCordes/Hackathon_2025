import 'package:collection/collection.dart';
import 'package:flutter_frontend/feature/login/role.enum.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Top-level provider that exposes the stored role. Use `ref.invalidate(jwtRoleProvider)`
/// to force refresh (e.g., after login/logout).
final jwtRoleProvider = FutureProvider<Role?>((ref) async {
  return JwtRepository().getRole();
});

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

  Future<void> setRole(Role role, {Ref? ref}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(roleKey, role.name);
    // If a Riverpod Ref is provided, invalidate the role provider so listeners update
    if (ref != null) {
      ref.invalidate(jwtRoleProvider);
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Clear stored JWT/role and notify Riverpod by invalidating [jwtRoleProvider].
  /// Call this from a Riverpod-aware location (e.g. inside a ConsumerWidget using `ref`).
  Future<void> clearAndNotify(Ref ref) async {
    await clear();
    // Invalidate the provider so listeners re-read the role (will become null)
    ref.invalidate(jwtRoleProvider);
  }
}
