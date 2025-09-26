// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dataset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Dataset _$DatasetFromJson(Map<String, dynamic> json) => Dataset(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String,
  category: $enumDecode(_$CategoryEnumMap, json['category']),
  dataFormat: $enumDecode(_$DataFormatEnumMap, json['dataFormat']),
  accessLevel: $enumDecode(_$AccessLevelEnumMap, json['accessLevel']),
  contactEmail: json['contactEmail'] as String?,
  contactName: json['contactName'] as String?,
  organization: json['organization'] as String?,
  dataUrl: json['dataUrl'] as String?,
  documentationUrl: json['documentationUrl'] as String?,
  requiresCertificate: json['requiresCertificate'] as bool,
  requiredCertificateTypes:
      (json['requiredCertificateTypes'] as List<dynamic>)
          .map((e) => CertificateType.fromJson(e as String))
          .toList(),
  certificateRequirements: json['certificateRequirements'] as String?,
  dataSensitivity: $enumDecode(
    _$DataSensitivityEnumMap,
    json['dataSensitivity'],
  ),
  accessRequests: json['accessRequests'] as List<dynamic>,
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updateFrequency: json['updateFrequency'] as String,
  licenseType: $enumDecode(_$LicenseTypeEnumMap, json['licenseType']),
  estimatedSize: (json['estimatedSize'] as num?)?.toInt(),
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  additionalMetadata: Map<String, String>.from(
    json['additionalMetadata'] as Map,
  ),
);

Map<String, dynamic> _$DatasetToJson(Dataset instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'category': _$CategoryEnumMap[instance.category]!,
  'dataFormat': _$DataFormatEnumMap[instance.dataFormat]!,
  'accessLevel': _$AccessLevelEnumMap[instance.accessLevel]!,
  'contactEmail': instance.contactEmail,
  'contactName': instance.contactName,
  'organization': instance.organization,
  'dataUrl': instance.dataUrl,
  'documentationUrl': instance.documentationUrl,
  'requiresCertificate': instance.requiresCertificate,
  'requiredCertificateTypes': instance.requiredCertificateTypes,
  'certificateRequirements': instance.certificateRequirements,
  'dataSensitivity': _$DataSensitivityEnumMap[instance.dataSensitivity]!,
  'accessRequests': instance.accessRequests,
  'lastUpdated': instance.lastUpdated.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updateFrequency': instance.updateFrequency,
  'licenseType': _$LicenseTypeEnumMap[instance.licenseType]!,
  'estimatedSize': instance.estimatedSize,
  'tags': instance.tags,
  'additionalMetadata': instance.additionalMetadata,
};

const _$CategoryEnumMap = {Category.government: 'GOVERNMENT'};

const _$DataFormatEnumMap = {DataFormat.csv: 'CSV'};

const _$AccessLevelEnumMap = {AccessLevel.public: 'PUBLIC'};

const _$DataSensitivityEnumMap = {DataSensitivity.public: 'PUBLIC'};

const _$LicenseTypeEnumMap = {
  LicenseType.cc0PublicDomain: 'CC0 - Public Domain',
};
