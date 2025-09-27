import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_frontend/feature/marketplace/data_requests.controller.dart';
import 'package:flutter_frontend/feature/marketplace/data_requests.model.dart';
import 'package:flutter_frontend/feature/my_datasets/my_datasets.controller.dart';
import 'package:flutter_frontend/feature/catalog/dataset.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DataRequestsScreen extends ConsumerWidget {
  const DataRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<DataRequestsModel> state = ref.watch(
      dataRequestsControllerProvider,
    );
    final myDatasetsState = ref.watch(myDatasetsControllerProvider);

    return state.when(
      data: (data) {
        if (data.requests.isEmpty) {
          return const Center(child: Text('Keine Anfragen vorhanden'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: data.requests.length,
          itemBuilder: (context, index) {
            final request = data.requests[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExpansionTile(
                title: Text(
                  request.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Kategorie', style: TextStyle(fontSize: 10)),
                        Chip(
                          label: Text(request.category),
                          backgroundColor: Colors.blue.shade50,
                          side: BorderSide.none,
                        ),
                      ],
                    ),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Priorität', style: TextStyle(fontSize: 10)),
                        Chip(
                          label: Text(request.priority),
                          backgroundColor: Colors.orange.shade50,
                          side: BorderSide.none,
                        ),
                      ],
                    ),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Status', style: TextStyle(fontSize: 10)),
                        Chip(
                          label: Text(request.status),
                          backgroundColor: Colors.green.shade50,
                          side: BorderSide.none,
                        ),
                      ],
                    ),
                  ],
                ),
                childrenPadding: const EdgeInsets.all(12),
                children: [
                  _buildDetail('Beschreibung', request.description),
                  _buildDetail('Kontakt', request.contactEmail),
                  _buildDetail('Verwendungszweck', request.intendedUse),
                  _buildDetail('Format', request.preferredFormat),
                  _buildDetail('Geografisch', request.geographicScope),
                  _buildDetail('Zeitraum', request.timeScope),
                  _buildDetail('Größe', request.dataSize),
                  _buildDetail('Update-Frequenz', request.updateFrequency),
                  _buildDetail('Erstellt', request.createdAt),
                  _buildDetail('Letzte Aktualisierung', request.lastUpdated),
                  if (request.closedAt != null)
                    _buildDetail('Geschlossen am', request.closedAt!),
                  if (request.closedReason != null)
                    _buildDetail('Schließgrund', request.closedReason!),
                  _buildDetail('Antworten', request.responseCount.toString()),
                  _buildDetail('Alter', request.formattedAge),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.reply),
                      label: const Text('Antworten'),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            String replyMessage = '';
                            Dataset? selectedDataset;
                            return StatefulBuilder(
                              builder: (BuildContext context, StateSetter setState) {
                                return myDatasetsState.when(
                                  loading: () => const AlertDialog(
                                    title: Text('Lade Datensätze...'),
                                    content: Center(child: CircularProgressIndicator()),
                                  ),
                                  error: (error, stack) => AlertDialog(
                                    title: const Text('Fehler'),
                                    content: Text('Fehler beim Laden der Datensätze: $error'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                  data: (data) {
                                    final datasets = data.datasources;
                                    if (datasets.isEmpty) {
                                      return AlertDialog(
                                        title: const Text('Keine Datensätze verfügbar'),
                                        content: const Text('Sie haben noch keine Datensätze erstellt.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      );
                                    }
                                    
                                    return AlertDialog(
                                      title: const Text('Antwort auf Anfrage'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextField(
                                            decoration: const InputDecoration(
                                              labelText: 'Nachricht',
                                              border: OutlineInputBorder(),
                                            ),
                                            onChanged: (value) => replyMessage = value,
                                            maxLines: 3,
                                          ),
                                          const SizedBox(height: 16),
                                          StatefulBuilder(
                                            builder: (context, setDropdownState) {
                                              return DropdownButtonFormField<Dataset>(
                                                decoration: const InputDecoration(
                                                  labelText: 'Datensatz auswählen',
                                                  border: OutlineInputBorder(),
                                                ),
                                                value: selectedDataset,
                                                items: datasets.map((ds) => DropdownMenuItem(
                                                  value: ds,
                                                  child: Text(ds.title),
                                                )).toList(),
                                                onChanged: (value) => setDropdownState(() => selectedDataset = value),
                                              );
                                            }
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          child: const Text('Abbrechen'),
                                          onPressed: () => Navigator.of(context).pop(),
                                        ),
                                        ElevatedButton(
                                          child: const Text('Antwort senden'),
                                          onPressed: () {
                                            // TODO: Handle reply logic with replyMessage and selectedDataset
                                            debugPrint('Antwort: $replyMessage, Datensatz: $selectedDataset');
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      }         
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      error: (err, stack) => Center(child: Text('Fehler: $err')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
