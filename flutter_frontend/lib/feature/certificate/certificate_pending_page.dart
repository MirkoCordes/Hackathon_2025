import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_frontend/feature/certificate/certificate_admin.controller.dart';
import 'package:flutter_frontend/feature/user/certificate.repository.dart';
import 'package:flutter_frontend/feature/user/certificate.entity.dart';
import 'package:flutter_frontend/shared/widgets/modern_cards.dart';
import 'package:flutter_frontend/shared/widgets/status_badge.dart';
import 'package:flutter_frontend/util/download_helper.dart';
import 'package:flutter_frontend/util/browser_download.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

class CertificatePendingPage extends ConsumerWidget {
  const CertificatePendingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingCertificatesControllerProvider);
    final theme = Theme.of(context);

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.admin_panel_settings,
                  color: theme.colorScheme.secondary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Zertifikatsverwaltung',
                      style: theme.textTheme.displayMedium,
                    ),
                    Text(
                      'Prüfen und genehmigen Sie eingereichte Zertifikate',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: pending.when(
            data: (list) => list.isEmpty ? _buildEmptyState(theme) : _buildCertificateList(list, ref, theme),
            loading: () => _buildLoadingState(theme),
            error: (e, st) => _buildErrorState(theme, e.toString()),
          ),
        ),
      ],
    );
  }

  Widget _buildCertificateList(List<Certificate> certificates, WidgetRef ref, ThemeData _) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: certificates.length,
      itemBuilder: (context, index) {
        final cert = certificates[index];
        return _CertificateCard(
          certificate: cert,
          onApprove: () => _handleApproval(context, ref, cert, 'APPROVED'),
          onReject: () => _handleApproval(context, ref, cert, 'REJECTED'),
          onDownload: () => _handleDownload(context, cert),
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 64,
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Alle Zertifikate bearbeitet',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'Es stehen keine Zertifikate zur Prüfung an.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            'Lade Zertifikate...',
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 24),
          Text(
            'Fehler beim Laden',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            error,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _handleApproval(BuildContext context, WidgetRef ref, Certificate cert, String action) async {
    try {
      await CertificateRepository().reviewCertificate(cert.id!, action);
      if (context.mounted) {
        final notifier = ref.read(pendingCertificatesControllerProvider.notifier);
        await notifier.refresh();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              action == 'APPROVED' ? 'Zertifikat genehmigt' : 'Zertifikat abgelehnt',
            ),
            backgroundColor: action == 'APPROVED' ? Colors.green : Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler bei der Bearbeitung: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _handleDownload(BuildContext context, Certificate cert) async {
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
        if (context.mounted) {
          await showDialog(
            context: context,
            builder:
                (ctx) => Dialog(
                  backgroundColor: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(ctx).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Zertifikat Vorschau',
                          style: Theme.of(ctx).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        Flexible(
                          child: InteractiveViewer(
                            child: Image.memory(
                              Uint8List.fromList(result.bytes),
                              semanticLabel: 'Zertifikatsvorschau',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          );
        }
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download fehlgeschlagen: $e')),
        );
      }
    }
  }
}

class _CertificateCard extends StatelessWidget {
  final Certificate certificate;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onDownload;

  const _CertificateCard({
    required this.certificate,
    required this.onApprove,
    required this.onReject,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ModernCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with type and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getTypeIcon(),
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      certificate.typeDisplayName,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge.pending(certificate.statusDisplayName),
            ],
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            certificate.description,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          // Filename if available
          if (certificate.filename != null)
            Row(
              children: [
                Icon(
                  Icons.attach_file,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    certificate.filename!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              // Download/Preview button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDownload,
                  icon: Icon(
                    _isImageFile() ? Icons.visibility : Icons.download,
                    size: 16,
                  ),
                  label: Text(_isImageFile() ? 'Anzeigen' : 'Herunterladen'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Reject button
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: onReject,
                  icon: Icon(
                    Icons.close_rounded,
                    color: theme.colorScheme.error,
                  ),
                  tooltip: 'Ablehnen',
                ),
              ),

              const SizedBox(width: 8),

              // Approve button
              Container(
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: onApprove,
                  icon: const Icon(
                    Icons.check_rounded,
                    color: Colors.green,
                  ),
                  tooltip: 'Genehmigen',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon() {
    // Map certificate types to icons
    final type = certificate.typeDisplayName.toLowerCase();
    if (type.contains('ausweis')) return Icons.badge;
    if (type.contains('lizenz')) return Icons.card_membership;
    if (type.contains('qualifikation')) return Icons.school;
    if (type.contains('berechtigung')) return Icons.verified_user;
    return Icons.document_scanner;
  }

  bool _isImageFile() {
    final filename = certificate.filename?.toLowerCase() ?? '';
    return filename.endsWith('.png') ||
        filename.endsWith('.jpg') ||
        filename.endsWith('.jpeg') ||
        filename.endsWith('.gif') ||
        filename.endsWith('.webp');
  }
}
