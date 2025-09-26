// dataset.dart

import 'package:flutter_frontend/feature/user/certificate.entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dataset.g.dart';

@JsonEnum()
enum Category {
  @JsonValue('GOVERNMENT')
  government,
}

@JsonEnum()
enum DataFormat {
  @JsonValue('CSV')
  csv,
}

@JsonEnum()
enum AccessLevel {
  @JsonValue('PUBLIC')
  public,
}

@JsonEnum()
enum DataSensitivity {
  @JsonValue('PUBLIC')
  public,
}

@JsonEnum()
enum LicenseType {
  @JsonValue('CC0 - Public Domain')
  cc0PublicDomain,
}

@JsonSerializable()
class Dataset {
  final int id;
  final String title;
  final String description;
  final Category category;
  final DataFormat dataFormat;
  final AccessLevel accessLevel;
  final String? contactEmail;
  final String? contactName;
  final String? organization;
  final String? dataUrl;
  final String? documentationUrl;
  final bool requiresCertificate;
  final List<CertificateType> requiredCertificateTypes;
  final String? certificateRequirements;
  final DataSensitivity dataSensitivity;
  final List<dynamic> accessRequests;
  final DateTime lastUpdated;
  final DateTime createdAt;
  final String updateFrequency;
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

  factory Dataset.fromJson(Map<String, dynamic> json) => _$DatasetFromJson(json);
  Map<String, dynamic> toJson() => _$DatasetToJson(this);
}
