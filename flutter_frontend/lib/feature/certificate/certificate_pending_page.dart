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
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getTypeColor(cert.type),
                        child: Icon(
                          _getTypeIcon(cert.type),
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        cert.description,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Chip(
                                label: Text(
                                  cert.type.category,
                                  style: const TextStyle(fontSize: 10),
                                ),
                                backgroundColor: _getTypeColor(cert.type).withOpacity(0.2),
                                side: BorderSide(color: _getTypeColor(cert.type)),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  cert.typeDisplayName,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                _getStatusIcon(cert.status),
                                size: 16,
                                color: _getStatusColor(cert.status),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                cert.statusDisplayName,
                                style: TextStyle(
                                  color: _getStatusColor(cert.status),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _formatDate(cert.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                    // Action buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
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
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text('Download failed: $e')));
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
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text('Approve failed: $e')));
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
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text('Reject failed: $e')));
                              }
                            },
                          ),
                        ],
                      ),
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

  // Helper methods for styling
  Color _getTypeColor(CertificateType type) {
    switch (type.category.toLowerCase()) {
      case 'government':
        return Colors.blue;
      case 'research':
        return Colors.purple;
      case 'professional':
        return Colors.green;
      case 'business':
        return Colors.orange;
      case 'ngo':
        return Colors.teal;
      case 'personal':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(CertificateType type) {
    switch (type.category.toLowerCase()) {
      case 'government':
        return Icons.account_balance;
      case 'research':
        return Icons.school;
      case 'professional':
        return Icons.work;
      case 'business':
        return Icons.business;
      case 'ngo':
        return Icons.favorite;
      case 'personal':
        return Icons.person;
      default:
        return Icons.description;
    }
  }

  Color _getStatusColor(CertificateStatus status) {
    switch (status) {
      case CertificateStatus.pending:
        return Colors.orange;
      case CertificateStatus.approved:
        return Colors.green;
      case CertificateStatus.rejected:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(CertificateStatus status) {
    switch (status) {
      case CertificateStatus.pending:
        return Icons.hourglass_empty;
      case CertificateStatus.approved:
        return Icons.check_circle;
      case CertificateStatus.rejected:
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unbekannt';
    return '${date.day}.${date.month}.${date.year}';
  }
}
