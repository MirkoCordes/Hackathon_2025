import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_frontend/feature/marketplace/data_requests.controller.dart';
import 'package:flutter_frontend/feature/marketplace/data_requests.model.dart';
import 'package:flutter_frontend/feature/marketplace/data_request_create.widget.dart';
import 'package:flutter_frontend/feature/my_datasets/my_datasets.controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_frontend/feature/marketplace/data_request_reply_dialog.dart';

class DataRequestsScreen extends ConsumerWidget {
  const DataRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<DataRequestsModel> state = ref.watch(
      dataRequestsControllerProvider,
    );
    final myDatasetsState = ref.watch(myDatasetsControllerProvider);

    return Column(
      children: [
        // Header mit Button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Neue Datenanfrage erstellen'),
            onPressed: () async {
              final controller = ref.read(dataRequestsControllerProvider.notifier);
              await _showDataRequestDialog(context, controller);
            },
          ),
        ),
        // Content
        Expanded(
          child: state.when(
            data: (data) {
              if (data.requests.isEmpty) {
                return const Center(
                  child: Text('Keine Anfragen vorhanden'),
                );
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
                        if (request.closedAt != null) _buildDetail('Geschlossen am', request.closedAt!),
                        if (request.closedReason != null) _buildDetail('Schließgrund', request.closedReason!),
                        _buildDetail('Antworten', request.responseCount.toString()),
                        _buildDetail('Alter', request.formattedAge),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.reply),
                            label: const Text('Antworten'),
                            onPressed: () async {
                              // Antwort-Dialog öffnen
                              await showDialog(
                                context: context,
                                builder:
                                    (context) => DataRequestReplyDialog(
                                      dataRequest: request,
                                      myDatasetsState: myDatasetsState,
                                      onSubmit: (response) async {
                                        debugPrint('Response erstellt: ${response.toJson()}');
                                        final controller = ref.read(dataRequestsControllerProvider.notifier);
                                        await controller.createResponse(request.id, response);
                                      },
                                    ),
                              );
                            },
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
          ),
        ),
      ],
    );
  }

  Future<void> _showDataRequestDialog(
    BuildContext context,
    DataRequestsController controller,
  ) async {
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
              child: DataRequestFormWidget(
                onSubmit: (dataRequest) async {
                  await controller.create(dataRequest);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ),
        );
      },
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
