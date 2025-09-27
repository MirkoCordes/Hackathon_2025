// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_request_response.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataRequestResponseModel _$DataRequestResponseModelFromJson(
  Map<String, dynamic> json,
) => DataRequestResponseModel(
  id: (json['id'] as num).toInt(),
  dataRequestId: (json['dataRequestId'] as num).toInt(),
  responderId: (json['responderId'] as num).toInt(),
  responseType: json['responseType'] as String,
  message: json['message'] as String,
  existingDatasourceId: (json['existingDatasourceId'] as num?)?.toInt(),
  proposedTitle: json['proposedTitle'] as String?,
  proposedDescription: json['proposedDescription'] as String?,
  estimatedDeliveryTime: json['estimatedDeliveryTime'] as String?,
  estimatedCost: json['estimatedCost'] as String?,
  proposedFormat: json['proposedFormat'] as String?,
  proposedAccessLevel: json['proposedAccessLevel'] as String?,
  status: json['status'] as String,
  createdAt: json['createdAt'] as String,
  lastUpdated: json['lastUpdated'] as String?,
  contactEmail: json['contactEmail'] as String?,
  contactPhone: json['contactPhone'] as String?,
  formattedAge: json['formattedAge'] as String,
  pending: json['pending'] as bool,
  accepted: json['accepted'] as bool,
);

Map<String, dynamic> _$DataRequestResponseModelToJson(
  DataRequestResponseModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'dataRequestId': instance.dataRequestId,
  'responderId': instance.responderId,
  'responseType': instance.responseType,
  'message': instance.message,
  'existingDatasourceId': instance.existingDatasourceId,
  'proposedTitle': instance.proposedTitle,
  'proposedDescription': instance.proposedDescription,
  'estimatedDeliveryTime': instance.estimatedDeliveryTime,
  'estimatedCost': instance.estimatedCost,
  'proposedFormat': instance.proposedFormat,
  'proposedAccessLevel': instance.proposedAccessLevel,
  'status': instance.status,
  'createdAt': instance.createdAt,
  'lastUpdated': instance.lastUpdated,
  'contactEmail': instance.contactEmail,
  'contactPhone': instance.contactPhone,
  'formattedAge': instance.formattedAge,
  'pending': instance.pending,
  'accepted': instance.accepted,
};
