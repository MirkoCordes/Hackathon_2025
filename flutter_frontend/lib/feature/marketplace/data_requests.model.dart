import 'package:flutter_frontend/feature/marketplace/data_request.model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'data_requests.model.g.dart';

@JsonSerializable(explicitToJson: true)
class DataRequestsModel {
  final List<DataRequestModel> requests;

  DataRequestsModel({required this.requests});

  factory DataRequestsModel.fromJson(Map<String, dynamic> json) =>
      _$DataRequestsModelFromJson(json);

  Map<String, dynamic> toJson() => _$DataRequestsModelToJson(this);
}
