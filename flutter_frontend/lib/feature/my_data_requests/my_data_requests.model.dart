import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_frontend/feature/marketplace/data_request.model.dart';
import 'package:flutter_frontend/feature/marketplace/data_request_response.model.dart';

part 'my_data_requests.model.g.dart';

@JsonSerializable(explicitToJson: true)
class MyDataRequestsModel {
  final List<DataRequestModel> requests;

  MyDataRequestsModel({
    required this.requests,
  });

  factory MyDataRequestsModel.fromJson(Map<String, dynamic> json) => _$MyDataRequestsModelFromJson(json);

  Map<String, dynamic> toJson() => _$MyDataRequestsModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class DataRequestWithResponses {
  final DataRequestModel request;
  final List<DataRequestResponseModel> responses;

  DataRequestWithResponses({
    required this.request,
    required this.responses,
  });

  factory DataRequestWithResponses.fromJson(Map<String, dynamic> json) => _$DataRequestWithResponsesFromJson(json);

  Map<String, dynamic> toJson() => _$DataRequestWithResponsesToJson(this);
}
