import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_frontend/feature/certificate/certificate_admin.controller.dart';
import 'package:flutter_frontend/feature/user/certificate.repository.dart';
import 'package:flutter_frontend/feature/user/certificate.entity.dart';
import 'package:flutter_frontend/util/download_helper.dart';
import 'package:flutter_frontend/util/browser_download.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

class CertificatePendingPage extends ConsumerWidget {
  const CertificatePendingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingCertificatesControllerProvider);

    // This widget is intentionally scaffold-free; the parent provides the scaffold.
    return pending.when(
      data:
          (list) => ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, idx) {
              final cert = list[idx];
              return ListTile(
                title: Text(cert.description),
                subtitle: Text('${cert.typeDisplayName} • ${cert.statusDisplayName}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.download),
                      onPressed: () async {
                        try {
                          final result = await CertificateRepository().downloadCertificateFile(cert.id!);
                          final filename = result.filename ?? cert.filename ?? 'certificate-${cert.id ?? ''}';
                          final mime = result.mimeType ?? '';

                          final isImage =
                              mime.toLowerCase().startsWith('image/') ||
                              filename.toLowerCase().endsWith('.png') ||
                              filename.toLowerCase().endsWith('.jpg') ||
                              filename.toLowerCase().endsWith('.jpeg') ||
                              filename.toLowerCase().endsWith('.gif') ||
                              filename.toLowerCase().endsWith('.webp');

                          if (isImage) {
                            // Prefer in-app preview for images on all platforms
                            await showDialog(
                              context: context,
                              builder:
                                  (ctx) => Dialog(
                                    child: InteractiveViewer(
                                      child: Image.memory(
                                        Uint8List.fromList(result.bytes),
                                        semanticLabel: 'Zertifikatsvorschau',
                                      ),
                                    ),
                                  ),
                            );
                          } else {
                            if (kIsWeb) {
                              triggerBrowserDownload(
                                Uint8List.fromList(result.bytes),
                                filename,
                                mimeType: mime.isNotEmpty ? mime : null,
                              );
                            } else {
                              await saveAndOpenFile(Uint8List.fromList(result.bytes), filename);
                            }
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Download failed: $e')));
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () async {
                        final notifier = ref.read(pendingCertificatesControllerProvider.notifier);
                        try {
                          await CertificateRepository().reviewCertificate(cert.id!, 'APPROVED');
                          await notifier.refresh();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Approve failed: $e')));
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () async {
                        final notifier = ref.read(pendingCertificatesControllerProvider.notifier);
                        try {
                          await CertificateRepository().reviewCertificate(cert.id!, 'REJECTED');
                          await notifier.refresh();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reject failed: $e')));
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Fehler: $e')),
    );
  }
}
