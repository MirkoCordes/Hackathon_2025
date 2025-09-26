// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_request.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataRequestModel _$DataRequestModelFromJson(Map<String, dynamic> json) =>
    DataRequestModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      priority: json['priority'] as String,
      status: json['status'] as String,
      contactEmail: json['contactEmail'] as String,
      intendedUse: json['intendedUse'] as String,
      preferredFormat: json['preferredFormat'] as String,
      geographicScope: json['geographicScope'] as String,
      timeScope: json['timeScope'] as String,
      dataSize: json['dataSize'] as String,
      updateFrequency: json['updateFrequency'] as String,
      createdAt: json['createdAt'] as String,
      lastUpdated: json['lastUpdated'] as String,
      closedAt: json['closedAt'] as String?,
      closedReason: json['closedReason'] as String?,
      open: json['open'] as bool,
      activeResponseIds: json['activeResponseIds'] as List<dynamic>,
      responseCount: (json['responseCount'] as num).toInt(),
      formattedAge: json['formattedAge'] as String,
      responseIds: json['responseIds'] as List<dynamic>,
      userId: (json['userId'] as num).toInt(),
    );

Map<String, dynamic> _$DataRequestModelToJson(DataRequestModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'priority': instance.priority,
      'status': instance.status,
      'contactEmail': instance.contactEmail,
      'intendedUse': instance.intendedUse,
      'preferredFormat': instance.preferredFormat,
      'geographicScope': instance.geographicScope,
      'timeScope': instance.timeScope,
      'dataSize': instance.dataSize,
      'updateFrequency': instance.updateFrequency,
      'createdAt': instance.createdAt,
      'lastUpdated': instance.lastUpdated,
      'closedAt': instance.closedAt,
      'closedReason': instance.closedReason,
      'open': instance.open,
      'activeResponseIds': instance.activeResponseIds,
      'responseCount': instance.responseCount,
      'formattedAge': instance.formattedAge,
      'responseIds': instance.responseIds,
      'userId': instance.userId,
    };
