import 'package:flutter/material.dart';
import 'package:flutter_frontend/feature/catalog/catalog.controller.dart';
import 'package:flutter_frontend/feature/catalog/catalog.state.dart';
import 'package:flutter_frontend/feature/catalog/dataset.dart';
import 'package:flutter_frontend/feature/catalog/search/catalog_search_bar.dart';
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

          const SizedBox(height: 16),

          // 2. Ersetzung der DataTable durch ListView.builder
          datasets.isNotEmpty
              ? Expanded(
                // Wichtig: ListView.builder benötigt definierte Grenzen
                child: Scrollbar(
                  thumbVisibility: true,
                  // ListView.builder ist effizient und von Natur aus scrollbar
                  child: ListView.builder(
                    itemCount: datasets.length,
                    // Fügen Sie horizontalen Padding zur Liste hinzu, um sie schmaler zu machen
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),

                    itemBuilder: (context, index) {
                      final e = datasets[index];
                      final Map<String, String> pathParams = {
                        'id': e.id.toString(),
                      };

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          // 3. Anzeige des Titels
                          title: Text(
                            e.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),

                          // 4. Anzeige der Beschreibung (unter dem Titel)
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              e.description,
                              maxLines: 2, // Begrenzung der Beschreibung
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // 5. Der Navigations-Button (Pfeil)
                          trailing: IconButton(
                            onPressed: () async {
                              await router.pushNamed(
                                'datasources',
                                pathParameters: pathParams,
                              );
                            },
                            icon: const Icon(Icons.arrow_forward),
                            color: Theme.of(context).colorScheme.primary,
                          ),

                          // Optional: Gesamten Eintrag klickbar machen
                          onTap: () async {
                            await router.pushNamed(
                              'datasources',
                              pathParameters: pathParams,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
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

/*
  Widget build(Object context, WidgetRef ref) {
    //List<DataRow>

    final CatalogState state = ref.watch(catalogControllerProvider);
    final List<Dataset> datasets = state.datasets;
    final Iterable<DataRow> dataRows = datasets.map((e) {
      final Map<String, String> pathParams = {'id': e.id.toString()};
      final List<DataCell> datacells = [
        DataCell(Text(e.title)),
        DataCell(Text(e.description)),
        DataCell(
          IconButton(
            onPressed: () async {
              await router.pushNamed('datasources', pathParameters: pathParams);
            },
            icon: Icon(Icons.arrow_forward, color: Colors.black),
          ),
        ),
      ];
      return DataRow(cells: datacells);
    });

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // TODO: search bar
          CatalogSearchBar(),
          // TODO: list view of katalogs
          dataRows.isNotEmpty
              ? Center(
                // Das SingleChildScrollView sorgt für die vertikale Scrollbarkeit
                child: SizedBox(
                  height: 800,
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      scrollDirection:
                          Axis.vertical, // Explizit für Vertikal setzen
                      child: DataTable(
                        columns: <DataColumn>[
                          DataColumn(label: Text("Titel")),
                          DataColumn(label: Text("Beschreibung")),
                          DataColumn(label: Text("Ansicht")),
                        ],
                        // Erstellt die DataRows aus der generierten Datenliste
                        rows: dataRows.toList(),
                      ),
                    ),
                  ),
                ),
              )
              : Text("\nHerzlich Willkommen auf dem Ostfriesland DataHub!"),
        ],
      ),
    );
  }
}

*/
