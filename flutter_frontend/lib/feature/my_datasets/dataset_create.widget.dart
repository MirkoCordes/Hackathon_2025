import 'package:flutter/material.dart';
import 'package:flutter_frontend/feature/catalog/dataset.dart';

class DatasetFormWidget extends StatefulWidget {
  final void Function(Dataset dataset) onSubmit;

  const DatasetFormWidget({super.key, required this.onSubmit});

  @override
  State<DatasetFormWidget> createState() => _DatasetFormWidgetState();
}

class _DatasetFormWidgetState extends State<DatasetFormWidget> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contactEmailController = TextEditingController();
  final TextEditingController _organizationController = TextEditingController();
  final TextEditingController _updateFrequencyController =
      TextEditingController();

  Category? _selectedCategory;
  DataFormat? _selectedFormat;
  AccessLevel? _selectedAccessLevel;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contactEmailController.dispose();
    _organizationController.dispose();
    _updateFrequencyController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final dataset = Dataset(
        id: 0,
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory ?? Category.government,
        dataFormat: _selectedFormat ?? DataFormat.csv,
        accessLevel: _selectedAccessLevel ?? AccessLevel.public,
        contactEmail:
            _contactEmailController.text.isEmpty
                ? null
                : _contactEmailController.text,
        contactName: null,
        organization:
            _organizationController.text.isEmpty
                ? null
                : _organizationController.text,
        dataUrl: null,
        documentationUrl: null,
        requiresCertificate: false,
        requiredCertificateTypes: [],
        certificateRequirements: null,
        dataSensitivity: DataSensitivity.public,
        accessRequests: [],
        lastUpdated: DateTime.now(),
        createdAt: DateTime.now(),
        updateFrequency: _updateFrequencyController.text,
        licenseType: '',
        estimatedSize: null,
        tags: [],
        additionalMetadata: {},
      );

      widget.onSubmit(dataset);
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
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Titel'),
              validator:
                  (v) => v == null || v.isEmpty ? 'Titel erforderlich' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Beschreibung'),
              maxLines: 3,
              validator:
                  (v) =>
                      v == null || v.isEmpty
                          ? 'Beschreibung erforderlich'
                          : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Category>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Kategorie'),
              items:
                  Category.values
                      .map(
                        (c) => DropdownMenuItem(value: c, child: Text(c.name)),
                      )
                      .toList(),
              onChanged: (v) => setState(() => _selectedCategory = v),
              validator: (v) => v == null ? 'Kategorie wählen' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<DataFormat>(
              value: _selectedFormat,
              decoration: const InputDecoration(labelText: 'Datenformat'),
              items:
                  DataFormat.values
                      .map(
                        (f) => DropdownMenuItem(value: f, child: Text(f.name)),
                      )
                      .toList(),
              onChanged: (v) => setState(() => _selectedFormat = v),
              validator: (v) => v == null ? 'Format wählen' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<AccessLevel>(
              value: _selectedAccessLevel,
              decoration: const InputDecoration(labelText: 'Zugriffslevel'),
              items:
                  AccessLevel.values
                      .map(
                        (a) => DropdownMenuItem(value: a, child: Text(a.name)),
                      )
                      .toList(),
              onChanged: (v) => setState(() => _selectedAccessLevel = v),
              validator: (v) => v == null ? 'Zugriffslevel wählen' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _contactEmailController,
              decoration: const InputDecoration(labelText: 'Kontakt E-Mail'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _organizationController,
              decoration: const InputDecoration(labelText: 'Organisation'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _updateFrequencyController,
              decoration: const InputDecoration(labelText: 'Update-Frequenz'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Dataset erstellen'),
            ),
          ],
        ),
      ),
    );
  }
}
