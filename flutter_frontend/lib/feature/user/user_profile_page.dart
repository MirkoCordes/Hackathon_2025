import 'package:flutter/material.dart';
import 'package:flutter_frontend/feature/certificate/certificate_upload.widget.dart';
import 'package:flutter_frontend/feature/user/user.entity.dart';
import 'package:flutter_frontend/feature/user/user.controller.dart';
import 'package:flutter_frontend/feature/user/certificate.controller.dart';
import 'package:flutter_frontend/feature/user/certificate.repository.dart';
import 'package:flutter_frontend/feature/user/certificate.entity.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// User Profile page that fetches the current user via Riverpod controller
class UserProfilePage extends ConsumerWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<User> state = ref.watch(userControllerProvider);

    return state.when(
      data:
          (displayUser) => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 32,
                      child: Icon(Icons.person, size: 36),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayUser.displayName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          displayUser.email,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ListTile(
                  title: const Text('Benutzername'),
                  subtitle: Text(displayUser.username),
                ),
                ListTile(
                  title: const Text('Vorname'),
                  subtitle: Text(displayUser.firstName ?? '-'),
                ),
                ListTile(
                  title: const Text('Nachname'),
                  subtitle: Text(displayUser.lastName ?? '-'),
                ),
                ListTile(
                  title: const Text('Organisation'),
                  subtitle: Text(displayUser.organization ?? '-'),
                ),
                ListTile(
                  title: const Text('Funktion/Titel'),
                  subtitle: Text(displayUser.jobTitle ?? '-'),
                ),
                ListTile(
                  title: const Text('Rolle'),
                  subtitle: Text(displayUser.role.displayName),
                ),
                const SizedBox(height: 12),

                // === Certificates Section ===
                const Divider(),
                const Text(
                  'Zertifikate',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // List of user's certificates (use outer ref)
                Builder(
                  builder: (context) {
                    final certState = ref.watch(
                      certificateListControllerProvider,
                    );
                    return certState.when(
                      data:
                          (certs) => Column(
                            children:
                                certs
                                    .map(
                                      (c) => ListTile(
                                        title: Text(c.description),
                                        subtitle: Text(
                                          '${c.typeDisplayName} • ${c.statusDisplayName}',
                                        ),
                                        trailing: Text(
                                          c.isActive ? 'Aktiv' : c.statusDisplayName,
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                      loading: () => const CircularProgressIndicator(),
                      error: (e, st) => Text('Fehler beim Laden der Zertifikate: $e'),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Upload form
                const Divider(),
                CertificateWidget(),
              ],
            ),
          ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Fehler: $e')),
    );
  }
}
