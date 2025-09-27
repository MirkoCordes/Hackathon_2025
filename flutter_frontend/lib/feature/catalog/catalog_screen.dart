import 'package:flutter/material.dart';
import 'package:flutter_frontend/feature/catalog/catalog.controller.dart';
import 'package:flutter_frontend/feature/catalog/catalog.state.dart';
import 'package:flutter_frontend/feature/catalog/dataset.dart';
import 'package:flutter_frontend/feature/catalog/dataset_list_widget.dart';
import 'package:flutter_frontend/feature/catalog/search/catalog_search_bar.dart';
import 'package:flutter_frontend/feature/filter/filter_list.screen.dart';
import 'package:flutter_frontend/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Riverpod State überwachen und Daten extrahieren
    final state = ref.watch(catalogControllerProvider);
    final List<Dataset> datasets = state.datasets;

    // Die GoRouter Instanz einmal abrufen (anstatt in jedem DataRow)
    //final router = GoRouter.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Suchleiste (bleibt gleich)
          const CatalogSearchBar(),
          const FilterListScreen(),
          //const SizedBox(height: 16, child: FilterListScreen()),
          const SizedBox(height: 16),

          // 2. Ersetzung der DataTable durch ListView.builder
          datasets.isNotEmpty
              ? Expanded(
                // Wichtig: ListView.builder benötigt definierte Grenzen
                child: DatasetListWidget(datasets: datasets),
              )
              : const Padding(
                padding: EdgeInsets.only(top: 40.0),
                child: Text(
                  "\nHerzlich Willkommen auf dem Ostfriesland DataHub!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
              ),
        ],
      ),
    );
  }
}
