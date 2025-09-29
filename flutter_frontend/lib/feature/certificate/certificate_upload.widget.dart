import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/feature/certificate/certificate_upload.controller.dart';
import 'package:flutter_frontend/feature/user/certificate.controller.dart';
import 'package:flutter_frontend/feature/user/certificate.entity.dart';
import 'package:flutter_frontend/feature/user/certificate.repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CertificateWidget extends ConsumerWidget {
  // Optionally pass a list of CertificateType that should be shown instead
  // of fetching available types from the backend.

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
      ],
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
    final state = ref.watch(certificateUploadControllerProvider);

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
      if (state.popOnSuccess) {
        Navigator.of(context).pop();
      }
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
    final state = ref.watch(certificateUploadControllerProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // If availableTypes are provided, show them directly; otherwise
        // fall back to the provider that fetches types from backend.
        if (state.availableTypes != null)
          DropdownButton<CertificateType>(
            value: _selectedType,
            hint: const Text('Typ auswählen'),
            items:
                state.availableTypes!
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.displayName),
                      ),
                    )
                    .toList(),
            onChanged: (v) => setState(() => _selectedType = v),
          )
        else
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
