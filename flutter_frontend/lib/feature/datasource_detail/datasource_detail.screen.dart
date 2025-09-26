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
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;

    return state.when(
      data: (dataset) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Allgemein (volle Breite)
                  _buildCard('Allgemein', [
                    _buildItem('ID', dataset.id.toString(), fullWidth: true),
                    _buildItem('Titel', dataset.title, fullWidth: true),
                    _buildItem(
                      'Beschreibung',
                      dataset.description,
                      fullWidth: true,
                    ),
                    _buildItem('Kategorie', dataset.category.name),
                    _buildItem('Datenformat', dataset.dataFormat.name),
                    _buildItem('Zugriffslevel', dataset.accessLevel.name),
                  ]),

                  // Kontakt (nebeneinander wenn möglich)
                  _buildCard('Kontakt', [
                    _buildItem('E-Mail', dataset.contactEmail ?? '-'),
                    _buildItem('Name', dataset.contactName ?? '-'),
                    _buildItem('Organisation', dataset.organization ?? '-'),
                  ], isWide: isWide),

                  // Zertifikat
                  _buildCard('Zertifikat', [
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
                      fullWidth: true,
                    ),
                  ], isWide: isWide),

                  // Technisch
                  _buildCard('Technische Details', [
                    _buildItem(
                      'Daten Sensitivität',
                      dataset.dataSensitivity.name,
                    ),
                    _buildItem(
                      'Zugriffsanfragen',
                      dataset.accessRequests.join(', '),
                      fullWidth: true,
                    ),
                    _buildItem(
                      'Letzte Aktualisierung',
                      dataset.lastUpdated.toString(),
                    ),
                    _buildItem('Erstellt am', dataset.createdAt.toString()),
                    _buildItem('Update-Frequenz', dataset.updateFrequency),
                    _buildItem('Lizenz', dataset.licenseType.name),
                    _buildItem(
                      'Geschätzte Größe',
                      dataset.estimatedSize?.toString() ?? '-',
                    ),
                    _buildItem('Tags', dataset.tags.join(','), fullWidth: true),
                    _buildItem(
                      'Zusätzliche Metadaten',
                      dataset.additionalMetadata.entries
                          .map((e) => '${e.key}: ${e.value}')
                          .join(', '),
                      fullWidth: true,
                    ),
                  ], isWide: isWide),
                ],
              ),
            ),
          ),
        );
      },
      error: (err, stack) => Center(child: Text('Fehler: $err')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  // Karte für Kategorie
  Widget _buildCard(String title, List<Widget> items, {bool isWide = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.15), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          isWide
              ? Wrap(
                spacing: 12,
                runSpacing: 12,
                children:
                    items
                        .map(
                          (item) => SizedBox(
                            width: 200, // kleine Items nebeneinander
                            child: item,
                          ),
                        )
                        .toList(),
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: items,
              ),
        ],
      ),
    );
  }

  // Einzelnes Item
  Widget _buildItem(String title, String value, {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
