// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_response.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CatalogResponse _$CatalogResponseFromJson(Map<String, dynamic> json) =>
    CatalogResponse(
      datasources:
          (json['datasources'] as List<dynamic>)
              .map((e) => Dataset.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$CatalogResponseToJson(CatalogResponse instance) =>
    <String, dynamic>{'datasources': instance.datasources};
