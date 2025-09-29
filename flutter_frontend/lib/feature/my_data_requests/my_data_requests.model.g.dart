// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_data_requests.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyDataRequestsModel _$MyDataRequestsModelFromJson(Map<String, dynamic> json) =>
    MyDataRequestsModel(
      requests:
          (json['requests'] as List<dynamic>)
              .map((e) => DataRequestModel.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$MyDataRequestsModelToJson(
  MyDataRequestsModel instance,
) => <String, dynamic>{
  'requests': instance.requests.map((e) => e.toJson()).toList(),
};

DataRequestWithResponses _$DataRequestWithResponsesFromJson(
  Map<String, dynamic> json,
) => DataRequestWithResponses(
  request: DataRequestModel.fromJson(json['request'] as Map<String, dynamic>),
  responses:
      (json['responses'] as List<dynamic>)
          .map(
            (e) => DataRequestResponseModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
);

Map<String, dynamic> _$DataRequestWithResponsesToJson(
  DataRequestWithResponses instance,
) => <String, dynamic>{
  'request': instance.request.toJson(),
  'responses': instance.responses.map((e) => e.toJson()).toList(),
};
