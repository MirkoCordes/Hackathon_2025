import 'package:flutter/material.dart';
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
                                          c.isActive
                                              ? 'Aktiv'
                                              : c.statusDisplayName,
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                      loading: () => const CircularProgressIndicator(),
                      error:
                          (e, st) =>
                              Text('Fehler beim Laden der Zertifikate: $e'),
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

class CertificateWidget extends ConsumerWidget {
  const CertificateWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const Text(
          'Neues Zertifikat hochladen',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _CertificateUploadForm(
          onUploaded: () async {
            // refresh certificates after upload
            try {
              ref.invalidate(certificateListControllerProvider);
            } catch (_) {}
          },
        ),
        TextButton(
          onPressed: showConfirmationDialog(),
          child: Text('Neues Zertifikat erstellen'),
        ),
      ],
    );
  }

  Future<void> showConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      // Der Builder erstellt das eigentliche Dialog-Widget
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Änderungen speichern'),
          content: const Text('Möchten Sie die Änderungen wirklich speichern?'),
          actions: <Widget>[
            // Button zum Schließen des Pop-ups ohne Aktion
            TextButton(
              child: const Text('ABBRECHEN'),
              onPressed: () {
                // Schließt den Dialog und gibt null zurück
                Navigator.of(context).pop();
              },
            ),
            // Button zum Bestätigen
            TextButton(
              child: const Text('SPEICHERN'),
              onPressed: () {
                // Führt eine Aktion aus und schließt dann
                print('Daten gespeichert.');
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Aufruf im Code (z.B. in einem onPressed-Callback):
  // await showConfirmationDialog(context);
}

class _CertificateUploadForm extends ConsumerStatefulWidget {
  final Future<void> Function() onUploaded;

  const _CertificateUploadForm({required this.onUploaded});

  @override
  _CertificateUploadFormState createState() => _CertificateUploadFormState();
}

class _CertificateUploadFormState
    extends ConsumerState<_CertificateUploadForm> {
  CertificateType? _selectedType;
  String _description = '';
  DateTime? _validUntil;
  File? _pickedFile;
  String? _pickedFileName;
  Uint8List? _pickedFileBytes;
  bool _submitting = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (!mounted) return;
    if (result != null && result.files.isNotEmpty) {
      final f = result.files.firstOrNull;
      if (f == null) return;
      setState(() {
        _pickedFileName = f.name;
        if (f.bytes != null) {
          debugPrint('Picked file with bytes, size: ${f.bytes!.length}');
          // Web: bytes are available
          _pickedFile = null;
          _pickedFileBytes = f.bytes;
        } else if (f.path != null) {
          // Native: we have a local path
          _pickedFile = File(f.path!);
          _pickedFileBytes = null;
        } else {
          // Fallback: clear
          _pickedFile = null;
          _pickedFileBytes = null;
        }
      });
    }
  }

  Future<void> _submit() async {
    // Validate inputs and provide feedback
    if (_selectedType == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bitte Typ auswählen')));
      return;
    }

    if (_pickedFile == null && _pickedFileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte eine Datei auswählen')),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _submitting = true);
    try {
      if (_pickedFile != null) {
        await CertificateRepository().upload(
          type: _selectedType!,
          description: _description,
          file: _pickedFile,
          validUntil: _validUntil,
        );
      } else if (_pickedFileBytes != null && _pickedFileName != null) {
        await CertificateRepository().upload(
          type: _selectedType!,
          description: _description,
          bytes: _pickedFileBytes,
          filename: _pickedFileName,
          validUntil: _validUntil,
        );
      } else {
        throw Exception('Keine Datei zum Hochladen ausgewählt');
      }

      // invalidate certificate list provider so it reloads
      try {
        ref.invalidate(certificateListControllerProvider);
      } catch (_) {}

      await widget.onUploaded();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Upload erfolgreich')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload fehlgeschlagen: $e')));
    } finally {
      if (!mounted) return;
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer(
          builder: (context, ref, _) {
            final typesState = ref.watch(certificateTypesControllerProvider);
            return typesState.when(
              data:
                  (types) => DropdownButton<CertificateType>(
                    value: _selectedType,
                    hint: const Text('Typ auswählen'),
                    items:
                        types
                            .map(
                              (t) => DropdownMenuItem(
                                value: t,
                                child: Text(t.displayName),
                              ),
                            )
                            .toList(),
                    onChanged: (v) => setState(() => _selectedType = v),
                  ),
              loading: () => const CircularProgressIndicator(),
              error: (e, st) => Text('Fehler beim Laden der Typen: $e'),
            );
          },
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(labelText: 'Beschreibung'),
          onChanged: (v) => _description = v,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton(
              onPressed: _pickFile,
              child: const Text('Datei auswählen'),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(_pickedFileName ?? 'Keine Datei gewählt')),
          ],
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _submit,
          child:
              _submitting
                  ? const CircularProgressIndicator()
                  : const Text('Hochladen'),
        ),
      ],
    );
  }
}
