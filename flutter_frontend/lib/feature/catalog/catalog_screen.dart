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
  Widget build(Object context, WidgetRef ref) {
    //List<DataRow>

    final CatalogState state = ref.watch(catalogControllerProvider);
    final List<Dataset> datasets = state.datasets;
    final Iterable<DataRow> dataRows = datasets.map((e) {
      final List<DataCell> datacells = [
        DataCell(Text(e.title)),
        DataCell(Text(e.description)),
        DataCell(
          IconButton(
            onPressed: () async {
              await router.pushNamed('datasources/${e.id}');
            },
            icon: Icon(Icons.edit, color: Colors.black),
          ),
        ),
      ];
      return DataRow(cells: datacells);
    });

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // TODO: search bar
          CatalogSearchBar(),
          // TODO: list view of katalogs
          DataTable(
            columns: <DataColumn>[
              DataColumn(label: Text("Title")),
              DataColumn(label: Text("Description")),
              DataColumn(label: Text("Edit")),
            ],
            rows: dataRows.toList(),
          ),
        ],
      ),
    );
  }
}
