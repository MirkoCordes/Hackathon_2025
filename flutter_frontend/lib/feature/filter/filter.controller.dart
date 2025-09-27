import 'package:flutter_frontend/feature/filter/filter_list.state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'filter.controller.g.dart';

@riverpod
class FilterController extends _$FilterController {
  /// Die 'build'-Methode muss den initialen Zustand des Providers zurückgeben.
  @override
  FilterListState build() {
    return FilterListState();
  }

  Future<void> updateFilter({
    category,
    dataFormat,
    accessLevel,
    dataSensitivity,
  }) async {
    state = FilterListState(
      category: category,
      dataFormat: dataFormat,
      accessLevel: accessLevel,
      dataSensitivity: dataSensitivity,
    );
  }
}
