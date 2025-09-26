// dataset.dart

import 'package:flutter_frontend/feature/user/certificate.entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dataset.g.dart';

@JsonEnum()
enum Category {
  @JsonValue('GOVERNMENT')
  government,
  unknown,
}

@JsonEnum()
enum DataFormat {
  @JsonValue('CSV')
  csv,
  @JsonValue('JSON')
  json,
  unknown,
}

@JsonEnum()
enum AccessLevel {
  @JsonValue('PUBLIC')
  public,
  unknown,
}

@JsonEnum()
enum DataSensitivity {
  @JsonValue('PUBLIC')
  public,
  unknown,
}

@JsonEnum()
enum LicenseType {
  @JsonValue('CC0 - Public Domain')
  cc0PublicDomain,
  @JsonValue('CC-BY 4.0')
  ccBy4,
  unknown,
}

@JsonSerializable()
class Dataset {
  final int id;
  final String title;
  final String description;
  @JsonKey(unknownEnumValue: Category.unknown)
  final Category category;
  @JsonKey(unknownEnumValue: DataFormat.unknown)
  final DataFormat dataFormat;
  @JsonKey(unknownEnumValue: AccessLevel.unknown)
  final AccessLevel accessLevel;
  final String? contactEmail;
  final String? contactName;
  final String? organization;
  final String? dataUrl;
  final String? documentationUrl;
  final bool requiresCertificate;
  final List<CertificateType> requiredCertificateTypes;
  final String? certificateRequirements;
  @JsonKey(unknownEnumValue: DataSensitivity.unknown)
  final DataSensitivity dataSensitivity;
  final List<dynamic> accessRequests;
  final DateTime lastUpdated;
  final DateTime createdAt;
  final String updateFrequency;
  @JsonKey(unknownEnumValue: LicenseType.unknown)
  final LicenseType licenseType;
  final int? estimatedSize;
  final List<String> tags;
  final Map<String, String> additionalMetadata;

  Dataset({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.dataFormat,
    required this.accessLevel,
    this.contactEmail,
    this.contactName,
    this.organization,
    this.dataUrl,
    this.documentationUrl,
    required this.requiresCertificate,
    required this.requiredCertificateTypes,
    this.certificateRequirements,
    required this.dataSensitivity,
    required this.accessRequests,
    required this.lastUpdated,
    required this.createdAt,
    required this.updateFrequency,
    required this.licenseType,
    this.estimatedSize,
    required this.tags,
    required this.additionalMetadata,
  });

  factory Dataset.fromJson(Map<String, dynamic> json) =>
      _$DatasetFromJson(json);
  Map<String, dynamic> toJson() => _$DatasetToJson(this);
}
