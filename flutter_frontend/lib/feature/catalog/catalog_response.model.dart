import 'package:flutter_frontend/feature/catalog/dataset.dart';
import 'package:json_annotation/json_annotation.dart';

part 'catalog_response.model.g.dart';

@JsonSerializable()
class CatalogResponse {
  final List<Dataset> datasets;

  CatalogResponse({required this.datasets});

  factory CatalogResponse.fromJson(Map<String, dynamic> json) =>
      _$CatalogResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CatalogResponseToJson(this);
}
