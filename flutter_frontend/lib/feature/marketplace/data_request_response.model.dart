import 'package:json_annotation/json_annotation.dart';

part 'data_request_response.model.g.dart';

@JsonSerializable(explicitToJson: true)
class DataRequestResponseModel {
  final int id;
  final int? dataRequestId;
  final int? responderId;
  final String responseType;
  final String message;

  // For existing datasources
  final int? existingDatasourceId;

  // For new datasources
  final String? proposedTitle;
  final String? proposedDescription;
  final String? estimatedDeliveryTime;
  final String? estimatedCost;
  final String? proposedFormat;
  final String? proposedAccessLevel;

  // Status & metadata
  final String status;
  final String createdAt;
  final String? lastUpdated;
  final String? contactEmail;
  final String? contactPhone;

  // Computed fields
  final String formattedAge;
  final bool pending;
  final bool accepted;

  DataRequestResponseModel({
    required this.id,
    this.dataRequestId,
    required this.responderId,
    required this.responseType,
    required this.message,
    this.existingDatasourceId,
    this.proposedTitle,
    this.proposedDescription,
    this.estimatedDeliveryTime,
    this.estimatedCost,
    this.proposedFormat,
    this.proposedAccessLevel,
    required this.status,
    required this.createdAt,
    this.lastUpdated,
    this.contactEmail,
    this.contactPhone,
    required this.formattedAge,
    required this.pending,
    required this.accepted,
  });

  factory DataRequestResponseModel.fromJson(Map<String, dynamic> json) => _$DataRequestResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$DataRequestResponseModelToJson(this);

  // Helper methods
  bool get isForExistingDatasource => responseType == 'EXISTING_DATASOURCE' && existingDatasourceId != null;

  bool get isForNewDatasource => responseType == 'NEW_DATASOURCE' && proposedTitle != null;

  bool get isPending => status == 'PENDING';
  bool get isAccepted => status == 'ACCEPTED';
  bool get isRejected => status == 'REJECTED';
  bool get isInProgress => status == 'IN_PROGRESS';
  bool get isCompleted => status == 'COMPLETED';
  bool get isWithdrawn => status == 'WITHDRAWN';
}

// Enums for ResponseType
enum DataRequestResponseType {
  @JsonValue('EXISTING_DATASOURCE')
  existingDatasource('EXISTING_DATASOURCE', 'Bestehende Datenquelle', 'Ich habe bereits eine passende Datenquelle'),

  @JsonValue('NEW_DATASOURCE')
  newDatasource('NEW_DATASOURCE', 'Neue Datenquelle', 'Ich kann eine neue Datenquelle erstellen'),

  @JsonValue('PARTIAL_MATCH')
  partialMatch('PARTIAL_MATCH', 'Teilweise passend', 'Meine Datenquelle erfüllt den Bedarf teilweise'),

  @JsonValue('COLLABORATION')
  collaboration('COLLABORATION', 'Kooperation', 'Ich möchte bei der Lösung mithelfen'),

  @JsonValue('INFORMATION')
  information('INFORMATION', 'Information', 'Ich habe weitere Informationen dazu');

  const DataRequestResponseType(this.value, this.displayName, this.description);

  final String value;
  final String displayName;
  final String description;
}

// Enums for Response Status
enum DataRequestResponseStatus {
  @JsonValue('PENDING')
  pending('PENDING', 'Ausstehend', 'warning'),

  @JsonValue('ACCEPTED')
  accepted('ACCEPTED', 'Akzeptiert', 'success'),

  @JsonValue('REJECTED')
  rejected('REJECTED', 'Abgelehnt', 'danger'),

  @JsonValue('IN_PROGRESS')
  inProgress('IN_PROGRESS', 'In Bearbeitung', 'info'),

  @JsonValue('COMPLETED')
  completed('COMPLETED', 'Abgeschlossen', 'primary'),

  @JsonValue('WITHDRAWN')
  withdrawn('WITHDRAWN', 'Zurückgezogen', 'secondary');

  const DataRequestResponseStatus(this.value, this.displayName, this.cssClass);

  final String value;
  final String displayName;
  final String cssClass;
}
