import 'package:flutter_frontend/feature/catalog/catalog.controller.dart';
import 'package:flutter_frontend/feature/filter/filter_list.state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'filter.controller.g.dart';

@riverpod
class FilterController extends _$FilterController {
  /// Die 'build'-Methode muss den initialen Zustand des Providers zurückgeben.
  @override
  FilterListState build() {
    print("Building initial filter state");
    return FilterListState();
  }

  Future<void> updateFilter({
    category,
    dataFormat,
    accessLevel,
    dataSensitivity,
  }) async {
    print(
      "Updating filter with: "
      "category=$category, "
      "dataFormat=$dataFormat, "
      "accessLevel=$accessLevel, "
      "dataSensitivity=$dataSensitivity",
    );
    state = FilterListState(
      category: category,
      dataFormat: dataFormat,
      accessLevel: accessLevel,
      dataSensitivity: dataSensitivity,
    );
    ref
        .read(catalogControllerProvider.notifier)
        .search(
          query: ref.read(catalogControllerProvider).searchQuery,
          category: category,
          dataFormat: dataFormat,
          accessLevel: accessLevel,
          dataSensitivity: dataSensitivity,
        );
  }
}
