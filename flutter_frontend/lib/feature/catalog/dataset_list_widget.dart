import 'package:flutter/material.dart';
import 'package:flutter_frontend/feature/catalog/catalog.controller.dart';
import 'package:flutter_frontend/feature/catalog/dataset.dart';
import 'package:flutter_frontend/feature/datasource_detail/datasource_detail.controller.dart';
import 'package:flutter_frontend/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DatasetListWidget extends StatelessWidget {
  const DatasetListWidget({super.key, required this.datasets});

  final List<Dataset> datasets;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
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
            trailing: DatasetListIconButton(e: e, pathParams: pathParams),

            // Optional: Gesamten Eintrag klickbar machen
            onTap: () async {
              if (e.hasAccess) {
                await router.pushNamed(
                  'datasources',
                  pathParameters: pathParams,
                );
              }
            },
            enabled: e.hasAccess,
          ),
        );
      },
    );
  }
}

class DatasetListIconButton extends ConsumerWidget {
  const DatasetListIconButton({
    super.key,
    required this.e,
    required this.pathParams,
  });

  final Dataset e;
  final Map<String, String> pathParams;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (e.hasAccess) {
      return IconButton(
        onPressed: () async {
          await router.pushNamed('datasources', pathParameters: pathParams);
        },
        icon: const Icon(Icons.arrow_forward),
        color: Theme.of(context).colorScheme.primary,
      );
    }

    return IconButton(
      onPressed: () async {
        // TODO: request new certificate

        await router.pushNamed('datasources', pathParameters: pathParams);
      },
      icon: const Icon(Icons.key),
      color: Theme.of(context).colorScheme.primary,
    );
  }
}
