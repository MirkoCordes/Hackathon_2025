import 'package:flutter/material.dart';
import 'package:flutter_frontend/feature/catalog/catalog.controller.dart';
import 'package:flutter_frontend/feature/catalog/dataset.dart';
import 'package:flutter_frontend/feature/catalog/dataset_list_widget.dart';
import 'package:flutter_frontend/shared/widgets/search_bar_modern.dart';
import 'package:flutter_frontend/shared/widgets/loading_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(catalogControllerProvider);
    final List<Dataset> datasets = state.datasets;
    final theme = Theme.of(context);

    return Column(
      children: [
        // Header section with search
        Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Datenkatalog',
                style: theme.textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Entdecken Sie verfügbare Datenquellen aus Ostfriesland',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 24),

              // Modern search bar
              SearchBarModern(
                hintText: 'Nach Datensätzen suchen...',
                onChanged: (query) async {
                  final controller = ref.read(catalogControllerProvider.notifier);
                  await controller.search(query);
                },
                onSubmitted: (query) async {
                  final controller = ref.read(catalogControllerProvider.notifier);
                  await controller.search(query);
                },
              ),
            ],
          ),
        ),

        // Dataset grid or empty state
        Expanded(
          child:
              datasets.isNotEmpty
                  ? DatasetListWidget(datasets: datasets)
                  : EmptyStateWidget(
                    icon: Icons.dashboard_rounded,
                    title: 'Willkommen im Datenraum Ostfriesland!',
                    description:
                        'Hier finden Sie Datenquellen aus Verwaltung,\nWirtschaft, Wissenschaft und Zivilgesellschaft.\n\nDie Datensätze werden gerade geladen...',
                  ),
        ),
      ],
    );
  }
}
