import 'package:flutter/material.dart';
import 'package:flutter_frontend/feature/catalog/catalog.controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CatalogSearchBar extends ConsumerWidget {
  const CatalogSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CatalogController controller = ref.read(
      catalogControllerProvider.notifier,
    );
    //final CatalogState state = ref.watch(catalogControllerProvider);
    return Padding(
      padding: EdgeInsetsGeometry.all(16),
      child: SearchBar(
        hintText: 'Datensatz durchsuchen ...',
        onChanged: (value) async => controller.search(value),
      ),
    );
  }
}
