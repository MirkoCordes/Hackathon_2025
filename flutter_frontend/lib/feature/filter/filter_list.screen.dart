import 'package:flutter/cupertino.dart';
import 'package:flutter_frontend/feature/catalog/catalog.controller.dart';
import 'package:flutter_frontend/feature/catalog/dataset.dart';
import 'package:flutter_frontend/feature/filter/filter.widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterListScreen extends ConsumerWidget {
  const FilterListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        FilterWidget(types: Category.values, typeName: 'Kategorie'),
        FilterWidget(types: DataFormat.values, typeName: 'Format'),
        FilterWidget(types: AccessLevel.values, typeName: 'Zugriffsart'),
        FilterWidget(
          types: DataSensitivity.values,
          typeName: 'Datensesibilität',
        ),
      ],
    );
  }
}
