// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'certificate.entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Certificate _$CertificateFromJson(Map<String, dynamic> json) => Certificate(
  id: (json['id'] as num?)?.toInt(),
  description: json['description'] as String,
  type: CertificateType.fromJson(json['type'] as String),
  status:
      json['status'] == null
          ? CertificateStatus.pending
          : CertificateStatus.fromJson(json['status'] as String),
  filename: json['filename'] as String?,
  filePath: json['filePath'] as String?,
  reviewNotes: json['reviewNotes'] as String?,
  validUntil:
      json['validUntil'] == null
          ? null
          : DateTime.parse(json['validUntil'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  reviewedAt:
      json['reviewedAt'] == null
          ? null
          : DateTime.parse(json['reviewedAt'] as String),
  userId: (json['userId'] as num?)?.toInt(),
);

Map<String, dynamic> _$CertificateToJson(Certificate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'type': instance.type,
      'status': instance.status,
      'filename': instance.filename,
      'filePath': instance.filePath,
      'reviewNotes': instance.reviewNotes,
      'validUntil': instance.validUntil?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'reviewedAt': instance.reviewedAt?.toIso8601String(),
      'userId': instance.userId,
    };
