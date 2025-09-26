import 'package:flutter/material.dart';
import 'package:flutter_frontend/feature/catalog/dataset.dart';
import 'package:flutter_frontend/feature/datasource_detail/datasource_detail.controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DatasourceDetailScreen extends ConsumerWidget {
  final String datasourceId;

  const DatasourceDetailScreen({super.key, required this.datasourceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Dataset> state = ref.watch(
      datasourceDetailControllerProvider(datasourceId),
    );
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {},
          child: Text(state.value?.description ?? 'asda'),
        ),
      ],
    );
  }
}
