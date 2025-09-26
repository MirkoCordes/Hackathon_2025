import 'package:flutter/material.dart';
import 'package:flutter_frontend/feature/catalog/dataset.dart';
import 'package:flutter_frontend/feature/datasource_detail/datasource_detail.controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DatasourceDetailScreen extends ConsumerWidget {
  final String datasourceId;

  const DatasourceDetailScreen({super.key, required this.datasourceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Dataset> state = ref.watch(
      datasourceDetailControllerProvider(datasourceId),
    );
    return state.when(
      data: (dataset) {
        return ListView(
          children: [
            _buildItem('ID', dataset.id.toString()),
            _buildItem('Titel', dataset.title),
            _buildItem('Beschreibung', dataset.description),
            _buildItem('Kategorie', dataset.category.name),
            _buildItem('Datenformat', dataset.dataFormat.name),
            _buildItem('Zugriffslevel', dataset.accessLevel.name),
            _buildItem('Kontakt E-Mail', dataset.contactEmail ?? '-'),
            _buildItem('Kontakt Name', dataset.contactName ?? '-'),
            _buildItem('Organisation', dataset.organization ?? '-'),
            _buildItem('Daten URL', dataset.dataUrl ?? '-'),
            _buildItem('Dokumentation URL', dataset.documentationUrl ?? '-'),
            _buildItem(
              'Benötigt Zertifikat',
              dataset.requiresCertificate ? 'Ja' : 'Nein',
            ),
            _buildItem(
              'Zertifikat Typen',
              dataset.requiredCertificateTypes.join(', '),
            ),
            _buildItem(
              'Zertifikat Anforderungen',
              dataset.certificateRequirements ?? '-',
            ),
            _buildItem('Daten Sensitivität', dataset.dataSensitivity.name),
            _buildItem('Zugriffsanfragen', dataset.accessRequests.join(', ')),
            _buildItem('Letzte Aktualisierung', dataset.lastUpdated.toString()),
            _buildItem('Erstellt am', dataset.createdAt.toString()),
            _buildItem('Update-Frequenz', dataset.updateFrequency),
            _buildItem('Lizenz', dataset.licenseType.name),
            _buildItem(
              'Geschätzte Größe',
              dataset.estimatedSize?.toString() ?? '-',
            ),
            _buildItem('Tags', dataset.tags.join(', ')),
            _buildItem(
              'Zusätzliche Metadaten',
              dataset.additionalMetadata.entries
                  .map((e) => '${e.key}: ${e.value}')
                  .join(', '),
            ),
          ],
        );
      },
      error: (err, stack) => Center(child: Text('Fehler: $err')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
