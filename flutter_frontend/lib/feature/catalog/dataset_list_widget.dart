import 'package:flutter/material.dart';
import 'package:flutter_frontend/feature/catalog/dataset.dart';
import 'package:flutter_frontend/router.dart';

class DatasetListWidget extends StatelessWidget {
  const DatasetListWidget({super.key, required this.datasets});

  final List<Dataset> datasets;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: datasets.length,
      // Fügen Sie horizontalen Padding zur Liste hinzu, um sie schmaler zu machen
      padding: const EdgeInsets.symmetric(horizontal: 24.0),

      itemBuilder: (context, index) {
        final e = datasets[index];
        final Map<String, String> pathParams = {'id': e.id.toString()};

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
              await router.pushNamed('datasources', pathParameters: pathParams);
            },
          ),
        );
      },
    );
  }
}
