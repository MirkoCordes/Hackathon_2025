// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_response.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CatalogResponse _$CatalogResponseFromJson(Map<String, dynamic> json) =>
    CatalogResponse(
      datasets:
          (json['datasets'] as List<dynamic>)
              .map((e) => Dataset.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$CatalogResponseToJson(CatalogResponse instance) =>
    <String, dynamic>{'datasets': instance.datasets};
