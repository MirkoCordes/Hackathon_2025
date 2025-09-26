import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_frontend/jwt.repository.dart';
import 'package:flutter_frontend/feature/login/role.enum.dart';

/// Minimal Riverpod-based widget that shows the review button when role != user.
class CertificateReviewWidget extends ConsumerWidget {
  const CertificateReviewWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleAsync = ref.watch(jwtRoleProvider);
    debugPrint('CertificateReviewWidget rebuild, roleAsync: $roleAsync');
    return roleAsync.when(
      data: (role) {
        if (role != null && role != Role.user) {
          return ElevatedButton(
            onPressed: () => Navigator.of(context).pushNamed('/certificates/pending'),
            child: const Text('Zertifikatsanträge überprüfen'),
          );
        }
        return Container();
      },
      loading: () => const SizedBox(width: 24, height: 24, child: CircularProgressIndicator()),
      error: (err, st) => const Text('Fehler beim Laden der Rolle'),
    );
  }
}
