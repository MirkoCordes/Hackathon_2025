import 'package:flutter/material.dart';
import 'package:flutter_frontend/feature/catalog/catalog_response.model.dart';
import 'package:flutter_frontend/feature/catalog/dataset_list_widget.dart';
import 'package:flutter_frontend/feature/my_datasets/dataset_create.widget.dart';
import 'package:flutter_frontend/feature/my_datasets/my_datasets.controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyDatasetsScreen extends ConsumerWidget {
  const MyDatasetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MyDatasetsController controller = ref.read(
      myDatasetsControllerProvider.notifier,
    );
    final AsyncValue<CatalogResponse> state = ref.watch(
      myDatasetsControllerProvider,
    );
    final screenWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: SizedBox(
        width: screenWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Neuen Datensatz hinzufügen'),
              onPressed: () async {
                await _showDatasetDialog(context, controller);
              },
            ),
            state.when(
              data: (data) {
                return DatasetListWidget(datasets: data.datasources);
              },
              error: (err, stack) => Center(child: Text('Fehler: $err')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDatasetDialog(
    BuildContext context,
    MyDatasetsController controller,
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
              constraints: const BoxConstraints(maxWidth: 500),
              child: DatasetFormWidget(
                onSubmit: (dataset) async {
                  await controller.create(dataset);
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
}
