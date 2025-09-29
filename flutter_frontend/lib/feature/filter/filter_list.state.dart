import 'package:flutter_frontend/feature/catalog/dataset.dart';

class FilterListState {
  final Category? category;
  final DataFormat? dataFormat;
  final AccessLevel? accessLevel;
  final DataSensitivity? dataSensitivity;

  const FilterListState({
    this.category,
    this.dataFormat,
    this.accessLevel,
    this.dataSensitivity,
  });
}
