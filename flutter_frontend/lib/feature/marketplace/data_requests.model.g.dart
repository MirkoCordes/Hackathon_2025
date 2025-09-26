// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_requests.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataRequestsModel _$DataRequestsModelFromJson(Map<String, dynamic> json) =>
    DataRequestsModel(
      requests:
          (json['requests'] as List<dynamic>)
              .map((e) => DataRequestModel.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$DataRequestsModelToJson(DataRequestsModel instance) =>
    <String, dynamic>{
      'requests': instance.requests.map((e) => e.toJson()).toList(),
    };
