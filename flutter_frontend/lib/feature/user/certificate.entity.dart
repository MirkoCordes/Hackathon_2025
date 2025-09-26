import 'package:flutter_frontend/feature/user/user.entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'certificate.entity.g.dart';

@JsonSerializable()
class Certificate {
  final int? id;
  final String description;
  final CertificateType type;
  final CertificateStatus status;
  @JsonKey(name: 'fileName')
  final String? filename;
  final String? filePath;
  final String? reviewNotes;

  @JsonKey(name: 'validUntil')
  final DateTime? validUntil;

  @JsonKey(name: 'createdAt')
  final DateTime createdAt;

  @JsonKey(name: 'reviewedAt')
  final DateTime? reviewedAt;

  // User reference - often loaded separately in mobile apps
  @JsonKey(name: 'userId')
  final int? userId;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final User? user;

  const Certificate({
    this.id,
    required this.description,
    required this.type,
    this.status = CertificateStatus.pending,
    this.filename,
    this.filePath,
    this.reviewNotes,
    this.validUntil,
    required this.createdAt,
    this.reviewedAt,
    this.userId,
    this.user,
  });

  // JSON Serialization
  factory Certificate.fromJson(Map<String, dynamic> json) => _$CertificateFromJson(json);
  Map<String, dynamic> toJson() => _$CertificateToJson(this);

  // Convenience getters
  bool get isActive {
    if (status != CertificateStatus.approved) return false;
    if (validUntil == null) return true;
    return DateTime.now().isBefore(validUntil!);
  }

  bool get isExpired {
    if (validUntil == null) return false;
    return DateTime.now().isAfter(validUntil!);
  }

  bool get isExpiringSoon {
    if (validUntil == null) return false;
    final daysUntilExpiry = validUntil!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry > 0;
  }

  String get statusDisplayName => status.displayName;
  String get typeDisplayName => type.displayName;

  // Copy method for immutability
  Certificate copyWith({
    int? id,
    String? description,
    CertificateType? type,
    CertificateStatus? status,
    String? filename,
    String? filePath,
    String? reviewNotes,
    DateTime? validUntil,
    DateTime? createdAt,
    DateTime? reviewedAt,
    int? userId,
    User? user,
  }) {
    return Certificate(
      id: id ?? this.id,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      filename: filename ?? this.filename,
      filePath: filePath ?? this.filePath,
      reviewNotes: reviewNotes ?? this.reviewNotes,
      validUntil: validUntil ?? this.validUntil,
      createdAt: createdAt ?? this.createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      userId: userId ?? this.userId,
      user: user ?? this.user,
    );
  }
}

enum CertificateStatus {
  @JsonValue('PENDING')
  pending('PENDING', 'Ausstehend'),

  @JsonValue('UNDER_REVIEW')
  underReview('UNDER_REVIEW', 'In Prüfung'),

  @JsonValue('APPROVED')
  approved('APPROVED', 'Genehmigt'),

  @JsonValue('REJECTED')
  rejected('REJECTED', 'Abgelehnt'),

  @JsonValue('EXPIRED')
  expired('EXPIRED', 'Abgelaufen');

  const CertificateStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  factory CertificateStatus.fromJson(String json) => values.firstWhere(
    (status) => status.value == json,
    orElse: () => CertificateStatus.pending,
  );

  String toJson() => value;

  bool get isActive => this == CertificateStatus.approved;
  bool get isPending => this == CertificateStatus.pending || this == CertificateStatus.underReview;
  bool get isRejected => this == CertificateStatus.rejected;
}

enum CertificateType {
  // Government certificates
  @JsonValue('GOVERNMENT_GENERAL')
  governmentGeneral('GOVERNMENT_GENERAL', 'Behörde Allgemein'),

  @JsonValue('GOVERNMENT_ENVIRONMENT')
  governmentEnvironment('GOVERNMENT_ENVIRONMENT', 'Behörde Umwelt'),

  @JsonValue('GOVERNMENT_HEALTH')
  governmentHealth('GOVERNMENT_HEALTH', 'Behörde Gesundheit'),

  @JsonValue('GOVERNMENT_STATISTICS')
  governmentStatistics('GOVERNMENT_STATISTICS', 'Behörde Statistik'),

  @JsonValue('GOVERNMENT_PLANNING')
  governmentPlanning('GOVERNMENT_PLANNING', 'Behörde Planung'),

  // Research certificates
  @JsonValue('RESEARCH_UNIVERSITY')
  researchUniversity('RESEARCH_UNIVERSITY', 'Universität'),

  @JsonValue('RESEARCH_ENVIRONMENTAL')
  researchEnvironmental('RESEARCH_ENVIRONMENTAL', 'Umweltforschung'),

  @JsonValue('RESEARCH_HEALTH')
  researchHealth('RESEARCH_HEALTH', 'Gesundheitsforschung'),

  @JsonValue('RESEARCH_SOCIAL')
  researchSocial('RESEARCH_SOCIAL', 'Sozialforschung'),

  @JsonValue('RESEARCH_ECONOMIC')
  researchEconomic('RESEARCH_ECONOMIC', 'Wirtschaftsforschung'),

  // Professional certificates
  @JsonValue('PROFESSIONAL_DOCTOR')
  professionalDoctor('PROFESSIONAL_DOCTOR', 'Arzt'),

  @JsonValue('PROFESSIONAL_LAWYER')
  professionalLawyer('PROFESSIONAL_LAWYER', 'Rechtsanwalt'),

  @JsonValue('PROFESSIONAL_ENGINEER')
  professionalEngineer('PROFESSIONAL_ENGINEER', 'Ingenieur'),

  @JsonValue('PROFESSIONAL_JOURNALIST')
  professionalJournalist('PROFESSIONAL_JOURNALIST', 'Journalist'),

  @JsonValue('PROFESSIONAL_CONSULTANT')
  professionalConsultant('PROFESSIONAL_CONSULTANT', 'Berater'),

  // Business certificates
  @JsonValue('BUSINESS_GENERAL')
  businessGeneral('BUSINESS_GENERAL', 'Unternehmen Allgemein'),

  @JsonValue('BUSINESS_ENVIRONMENTAL')
  businessEnvironmental('BUSINESS_ENVIRONMENTAL', 'Umwelttechnik'),

  @JsonValue('BUSINESS_HEALTHCARE')
  businessHealthcare('BUSINESS_HEALTHCARE', 'Gesundheitswesen'),

  @JsonValue('BUSINESS_CONSULTING')
  businessConsulting('BUSINESS_CONSULTING', 'Beratung'),

  @JsonValue('BUSINESS_MEDIA')
  businessMedia('BUSINESS_MEDIA', 'Medien'),

  // NGO certificates
  @JsonValue('NGO_ENVIRONMENTAL')
  ngoEnvironmental('NGO_ENVIRONMENTAL', 'Umwelt-NGO'),

  @JsonValue('NGO_SOCIAL')
  ngoSocial('NGO_SOCIAL', 'Sozial-NGO'),

  @JsonValue('NGO_TRANSPARENCY')
  ngoTransparency('NGO_TRANSPARENCY', 'Transparenz-NGO'),

  // Personal certificates
  @JsonValue('PERSONAL_ID')
  personalId('PERSONAL_ID', 'Personalausweis'),

  @JsonValue('OTHER')
  other('OTHER', 'Sonstiges');

  const CertificateType(this.value, this.displayName);

  final String value;
  final String displayName;

  factory CertificateType.fromJson(String json) => values.firstWhere(
    (type) => type.value == json,
    orElse: () => CertificateType.other,
  );

  String toJson() => value;

  // Helper getters for UI organization
  bool get isGovernment => value.startsWith('GOVERNMENT_');
  bool get isResearch => value.startsWith('RESEARCH_');
  bool get isProfessional => value.startsWith('PROFESSIONAL_');
  bool get isBusiness => value.startsWith('BUSINESS_');
  bool get isNgo => value.startsWith('NGO_');
  bool get isPersonal => value.startsWith('PERSONAL_');

  String get category {
    if (isGovernment) return 'Behörden';
    if (isResearch) return 'Forschung';
    if (isProfessional) return 'Berufsverbände';
    if (isBusiness) return 'Unternehmen';
    if (isNgo) return 'NGOs';
    if (isPersonal) return 'Persönlich';
    return 'Sonstiges';
  }
}
