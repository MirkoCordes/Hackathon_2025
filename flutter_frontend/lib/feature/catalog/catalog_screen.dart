import 'package:flutter/material.dart';
import 'package:flutter_frontend/feature/catalog/search/catalog_search_screen.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(Object context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // TODO: search bar
          CatalogSearchScreen(),
          // TODO: list view of katalogs
          const Text('You have pushed the button this many times:'),
          //Text('$_counter', style: Theme.of(context).textTheme.headlineMedium),
        ],
      ),
    );
  }
}
