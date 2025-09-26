import 'package:flutter/material.dart';
import 'package:flutter_frontend/feature/catalog/catalog.controller.dart';
import 'package:flutter_frontend/feature/catalog/catalog.state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CatalogSearchBar extends ConsumerWidget {
  const CatalogSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CatalogController controller = ref.read(catalogControllerProvider.notifier);
    CatalogState state = ref.watch(catalogControllerProvider);
    return SearchBar(onChanged: (value) => controller.search(value));
  }
}
