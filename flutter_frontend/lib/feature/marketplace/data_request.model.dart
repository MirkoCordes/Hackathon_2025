import 'package:json_annotation/json_annotation.dart';

part 'data_request.model.g.dart';

@JsonSerializable(explicitToJson: true)
class DataRequestModel {
  final int id;
  final String title;
  final String description;
  final String category;
  final String priority;
  final String status;
  final String contactEmail;
  final String intendedUse;
  final String preferredFormat;
  final String geographicScope;
  final String timeScope;
  final String dataSize;
  final String updateFrequency;
  final String createdAt;
  final String lastUpdated;
  final String? closedAt;
  final String? closedReason;
  final bool open;
  final int likes;
  final List<dynamic> activeResponseIds;
  final int responseCount;
  final String formattedAge;
  final List<dynamic> responseIds;
  final int userId;

  DataRequestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.contactEmail,
    required this.intendedUse,
    required this.preferredFormat,
    required this.geographicScope,
    required this.timeScope,
    required this.dataSize,
    required this.updateFrequency,
    required this.createdAt,
    required this.lastUpdated,
    this.closedAt,
    this.closedReason,
    required this.open,
    required this.likes,
    required this.activeResponseIds,
    required this.responseCount,
    required this.formattedAge,
    required this.responseIds,
    required this.userId,
  });

  factory DataRequestModel.fromJson(Map<String, dynamic> json) =>
      _$DataRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$DataRequestModelToJson(this);
}
