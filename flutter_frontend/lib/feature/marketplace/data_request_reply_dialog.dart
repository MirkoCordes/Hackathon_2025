import 'package:flutter/material.dart';
import 'package:flutter_frontend/feature/catalog/catalog_response.model.dart';
import 'package:flutter_frontend/feature/catalog/dataset.dart';
import 'package:flutter_frontend/feature/marketplace/data_request.model.dart';
import 'package:flutter_frontend/feature/marketplace/data_request_response.model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Dialog widget for responding to a data request
class DataRequestReplyDialog extends ConsumerStatefulWidget {
  final DataRequestModel dataRequest;
  final AsyncValue<CatalogResponse> myDatasetsState;
  final Function(DataRequestResponseModel response) onSubmit;

  const DataRequestReplyDialog({
    super.key,
    required this.dataRequest,
    required this.myDatasetsState,
    required this.onSubmit,
  });

  @override
  ConsumerState<DataRequestReplyDialog> createState() => _DataRequestReplyDialogState();
}

class _DataRequestReplyDialogState extends ConsumerState<DataRequestReplyDialog> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _contactEmailController = TextEditingController();
  final TextEditingController _contactPhoneController = TextEditingController();
  final TextEditingController _proposedTitleController = TextEditingController();
  final TextEditingController _proposedDescriptionController = TextEditingController();
  final TextEditingController _estimatedDeliveryTimeController = TextEditingController();
  final TextEditingController _estimatedCostController = TextEditingController();
  final TextEditingController _proposedFormatController = TextEditingController();

  Dataset? _selectedDataset;
  DataRequestResponseType _selectedResponseType = DataRequestResponseType.existingDatasource;
  String _selectedAccessLevel = 'PUBLIC';

  @override
  void dispose() {
    _messageController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _proposedTitleController.dispose();
    _proposedDescriptionController.dispose();
    _estimatedDeliveryTimeController.dispose();
    _estimatedCostController.dispose();
    _proposedFormatController.dispose();
    super.dispose();
  }

  DataRequestResponseModel _createResponseModel() {
    final now = DateTime.now().toIso8601String();

    return DataRequestResponseModel(
      id: 0, // Will be set by backend
      dataRequestId: widget.dataRequest.id,
      responderId: 0, // Will be set by backend with current user
      responseType: _selectedResponseType.value,
      message: _messageController.text.trim(),
      existingDatasourceId:
          (_selectedResponseType == DataRequestResponseType.existingDatasource ||
                  _selectedResponseType == DataRequestResponseType.partialMatch)
              ? _selectedDataset?.id
              : null,
      proposedTitle:
          _selectedResponseType == DataRequestResponseType.newDatasource
              ? _proposedTitleController.text.trim().isNotEmpty
                  ? _proposedTitleController.text.trim()
                  : null
              : null,
      proposedDescription:
          _selectedResponseType == DataRequestResponseType.newDatasource
              ? _proposedDescriptionController.text.trim().isNotEmpty
                  ? _proposedDescriptionController.text.trim()
                  : null
              : null,
      estimatedDeliveryTime:
          _estimatedDeliveryTimeController.text.trim().isNotEmpty ? _estimatedDeliveryTimeController.text.trim() : null,
      estimatedCost: _estimatedCostController.text.trim().isNotEmpty ? _estimatedCostController.text.trim() : null,
      proposedFormat: _proposedFormatController.text.trim().isNotEmpty ? _proposedFormatController.text.trim() : null,
      proposedAccessLevel: _selectedResponseType == DataRequestResponseType.newDatasource ? _selectedAccessLevel : null,
      status: DataRequestResponseStatus.pending.value,
      createdAt: now,
      contactEmail: _contactEmailController.text.trim().isNotEmpty ? _contactEmailController.text.trim() : null,
      contactPhone: _contactPhoneController.text.trim().isNotEmpty ? _contactPhoneController.text.trim() : null,
      formattedAge: 'Gerade erstellt',
      pending: true,
      accepted: false,
    );
  }

  bool _isFormValid() {
    if (_messageController.text.trim().isEmpty) return false;

    if (_selectedResponseType == DataRequestResponseType.existingDatasource ||
        _selectedResponseType == DataRequestResponseType.partialMatch) {
      return _selectedDataset != null;
    }

    if (_selectedResponseType == DataRequestResponseType.newDatasource) {
      return _proposedTitleController.text.trim().isNotEmpty && _proposedDescriptionController.text.trim().isNotEmpty;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return widget.myDatasetsState.when(
      loading:
          () => const AlertDialog(
            title: Text('Lade Datensätze...'),
            content: SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      error:
          (error, stack) => AlertDialog(
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
            content: const Text(
              'Sie haben noch keine Datensätze erstellt.\n\nUm auf eine Datenanfrage zu antworten, müssen Sie zunächst eigene Datensätze erstellen.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        }

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Text(
                    'Antwort auf Datenanfrage',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Request info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Anfrage: ${widget.dataRequest.title}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.dataRequest.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Form
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Response Type Selection
                          DropdownButtonFormField<DataRequestResponseType>(
                            decoration: const InputDecoration(
                              labelText: 'Art der Antwort *',
                              border: OutlineInputBorder(),
                            ),
                            value: _selectedResponseType,
                            items:
                                DataRequestResponseType.values
                                    .map(
                                      (type) => DropdownMenuItem<DataRequestResponseType>(
                                        value: type,
                                        child: Tooltip(
                                          message: type.description,
                                          child: Text(
                                            type.displayName,
                                            style: const TextStyle(fontWeight: FontWeight.w500),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (DataRequestResponseType? value) {
                              setState(() {
                                _selectedResponseType = value!;
                                // Reset dataset selection when switching types
                                if (_selectedResponseType != DataRequestResponseType.existingDatasource &&
                                    _selectedResponseType != DataRequestResponseType.partialMatch) {
                                  _selectedDataset = null;
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          // Message field
                          TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              labelText: 'Ihre Nachricht *',
                              hintText: 'Beschreiben Sie, wie Sie helfen können...',
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true,
                            ),
                            maxLines: 4,
                            textInputAction: TextInputAction.newline,
                          ),
                          const SizedBox(height: 16),

                          // Dataset selection (for existing datasource and partial match)
                          if (_selectedResponseType == DataRequestResponseType.existingDatasource ||
                              _selectedResponseType == DataRequestResponseType.partialMatch) ...[
                            DropdownButtonFormField<Dataset>(
                              decoration: InputDecoration(
                                labelText:
                                    _selectedResponseType == DataRequestResponseType.existingDatasource
                                        ? 'Bestehender Datensatz *'
                                        : 'Teilweise passender Datensatz *',
                                hintText: 'Wählen Sie einen Datensatz aus...',
                                border: const OutlineInputBorder(),
                              ),
                              value: _selectedDataset,
                              items: [
                                const DropdownMenuItem<Dataset>(
                                  value: null,
                                  child: Text(
                                    'Bitte wählen Sie einen Datensatz',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                ...datasets.map(
                                  (dataset) => DropdownMenuItem<Dataset>(
                                    value: dataset,
                                    child: Tooltip(
                                      message: dataset.description.isNotEmpty ? dataset.description : dataset.title,
                                      child: Text(
                                        dataset.title,
                                        style: const TextStyle(fontWeight: FontWeight.w500),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (Dataset? value) {
                                setState(() {
                                  _selectedDataset = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                          ],

                          // New datasource fields (only for new datasource type)
                          if (_selectedResponseType == DataRequestResponseType.newDatasource) ...[
                            TextField(
                              controller: _proposedTitleController,
                              decoration: const InputDecoration(
                                labelText: 'Titel der neuen Datenquelle *',
                                hintText: 'Beschreibender Titel...',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),

                            TextField(
                              controller: _proposedDescriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Beschreibung *',
                                hintText: 'Detaillierte Beschreibung der Datenquelle...',
                                border: OutlineInputBorder(),
                                alignLabelWithHint: true,
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _estimatedDeliveryTimeController,
                                    decoration: const InputDecoration(
                                      labelText: 'Geschätzte Lieferzeit',
                                      hintText: 'z.B. 2 Wochen',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextField(
                                    controller: _estimatedCostController,
                                    decoration: const InputDecoration(
                                      labelText: 'Geschätzte Kosten',
                                      hintText: 'z.B. 500€',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _proposedFormatController,
                                    decoration: const InputDecoration(
                                      labelText: 'Datenformat',
                                      hintText: 'z.B. JSON, CSV, XML',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                      labelText: 'Zugriffslevel',
                                      border: OutlineInputBorder(),
                                    ),
                                    value: _selectedAccessLevel,
                                    items: const [
                                      DropdownMenuItem(value: 'PUBLIC', child: Text('Öffentlich')),
                                      DropdownMenuItem(value: 'RESTRICTED', child: Text('Eingeschränkt')),
                                      DropdownMenuItem(value: 'PRIVATE', child: Text('Privat')),
                                    ],
                                    onChanged: (String? value) {
                                      setState(() {
                                        _selectedAccessLevel = value!;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Contact information (for all types)
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _contactEmailController,
                                  decoration: const InputDecoration(
                                    labelText: 'Kontakt E-Mail',
                                    hintText: 'ihre.email@domain.de',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: _contactPhoneController,
                                  decoration: const InputDecoration(
                                    labelText: 'Telefon (optional)',
                                    hintText: '+49 123 456789',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.phone,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Info text
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.amber.shade700, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Ihre Antwort wird an den Anfragenden gesendet.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.amber.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Abbrechen'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              !_isFormValid()
                                  ? null
                                  : () {
                                    final response = _createResponseModel();
                                    widget.onSubmit(response);
                                    Navigator.of(context).pop();
                                  },
                          child: const Text('Antwort senden'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
