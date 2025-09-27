import 'package:flutter/material.dart';
import 'package:flutter_frontend/feature/marketplace/data_request.model.dart';

class DataRequestFormWidget extends StatefulWidget {
  final void Function(DataRequestModel dataRequest) onSubmit;

  const DataRequestFormWidget({super.key, required this.onSubmit});

  @override
  State<DataRequestFormWidget> createState() => _DataRequestFormWidgetState();
}

class _DataRequestFormWidgetState extends State<DataRequestFormWidget> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contactEmailController = TextEditingController();
  final TextEditingController _intendedUseController = TextEditingController();
  final TextEditingController _geographicScopeController = TextEditingController();
  final TextEditingController _timeScopeController = TextEditingController();
  final TextEditingController _dataSizeController = TextEditingController();

  String _selectedCategory = 'GOVERNMENT';
  String _selectedPriority = 'MEDIUM';
  String _selectedPreferredFormat = 'CSV';
  String _selectedUpdateFrequency = 'MONTHLY';

  final List<String> _categories = [
    'GOVERNMENT',
    'BUSINESS',
    'SCIENCE',
    'CIVIL_SOCIETY',
    'TRANSPORT',
    'ENVIRONMENT',
    'EDUCATION',
    'HEALTH',
    'OTHER',
  ];

  final List<String> _priorities = ['LOW', 'MEDIUM', 'HIGH', 'URGENT'];

  final List<String> _formats = ['CSV', 'JSON', 'XML', 'PDF', 'EXCEL', 'DATABASE', 'API', 'OTHER'];

  final List<String> _updateFrequencies = [
    'REAL_TIME',
    'DAILY',
    'WEEKLY',
    'MONTHLY',
    'QUARTERLY',
    'YEARLY',
    'ON_DEMAND',
    'ONE_TIME',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contactEmailController.dispose();
    _intendedUseController.dispose();
    _geographicScopeController.dispose();
    _timeScopeController.dispose();
    _dataSizeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final dataRequest = DataRequestModel(
        id: 0, // Will be set by backend
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        priority: _selectedPriority,
        status: 'OPEN',
        contactEmail: _contactEmailController.text.isEmpty ? '' : _contactEmailController.text,
        intendedUse: _intendedUseController.text.isEmpty ? '' : _intendedUseController.text,
        preferredFormat: _selectedPreferredFormat,
        geographicScope: _geographicScopeController.text.isEmpty ? '' : _geographicScopeController.text,
        timeScope: _timeScopeController.text.isEmpty ? '' : _timeScopeController.text,
        dataSize: _dataSizeController.text.isEmpty ? '' : _dataSizeController.text,
        updateFrequency: _selectedUpdateFrequency,
        createdAt: '', // Will be set by backend
        lastUpdated: '', // Will be set by backend
        closedAt: null,
        closedReason: null,
        open: true,
        activeResponseIds: [],
        responseCount: 0,
        formattedAge: '',
        responseIds: [],
        userId: 0, // Will be set by backend
      );

      widget.onSubmit(dataRequest);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Neue Datenanfrage erstellen',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titel*',
                hintText: 'Was für Daten werden benötigt?',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Titel ist erforderlich' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Beschreibung*',
                hintText: 'Detaillierte Beschreibung des Datenbedarfs',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              validator: (v) => v == null || v.isEmpty ? 'Beschreibung ist erforderlich' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Kategorie*',
                border: OutlineInputBorder(),
              ),
              items:
                  _categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category.replaceAll('_', ' ')),
                        ),
                      )
                      .toList(),
              onChanged: (v) => setState(() => _selectedCategory = v!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Priorität*',
                border: OutlineInputBorder(),
              ),
              items:
                  _priorities
                      .map(
                        (priority) => DropdownMenuItem(
                          value: priority,
                          child: Text(priority),
                        ),
                      )
                      .toList(),
              onChanged: (v) => setState(() => _selectedPriority = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contactEmailController,
              decoration: const InputDecoration(
                labelText: 'Kontakt E-Mail',
                hintText: 'Falls anders als Ihre Benutzer-E-Mail',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _intendedUseController,
              decoration: const InputDecoration(
                labelText: 'Verwendungszweck',
                hintText: 'Wofür werden die Daten benötigt?',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedPreferredFormat,
              decoration: const InputDecoration(
                labelText: 'Gewünschtes Format',
                border: OutlineInputBorder(),
              ),
              items:
                  _formats
                      .map(
                        (format) => DropdownMenuItem(
                          value: format,
                          child: Text(format),
                        ),
                      )
                      .toList(),
              onChanged: (v) => setState(() => _selectedPreferredFormat = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _geographicScopeController,
              decoration: const InputDecoration(
                labelText: 'Geografischer Bereich',
                hintText: 'z.B. Ostfriesland, Niedersachsen',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _timeScopeController,
              decoration: const InputDecoration(
                labelText: 'Zeitraum',
                hintText: 'z.B. 2020-2024, laufend',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dataSizeController,
              decoration: const InputDecoration(
                labelText: 'Ungefähre Datenmenge',
                hintText: 'z.B. < 1GB, mehrere TB',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedUpdateFrequency,
              decoration: const InputDecoration(
                labelText: 'Gewünschte Update-Frequenz',
                border: OutlineInputBorder(),
              ),
              items:
                  _updateFrequencies
                      .map(
                        (frequency) => DropdownMenuItem(
                          value: frequency,
                          child: Text(frequency.replaceAll('_', ' ')),
                        ),
                      )
                      .toList(),
              onChanged: (v) => setState(() => _selectedUpdateFrequency = v!),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Abbrechen'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Anfrage erstellen'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
