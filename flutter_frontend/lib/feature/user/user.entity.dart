import 'package:flutter_frontend/feature/catalog/dataset.dart';
import 'package:flutter_frontend/feature/user/certificate.entity.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_frontend/feature/user/certificate.entity.dart';

part 'user.entity.g.dart';

@JsonSerializable()
class User {
  final int? id;
  final String username;
  final String email;

  // Password wird normalerweise nicht vom Backend gesendet
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? password;

  final UserRole role;
  final bool enabled;

  // Profile Information
  @JsonKey(name: 'firstName')
  final String? firstName;

  @JsonKey(name: 'lastName')
  final String? lastName;

  final String? organization;

  @JsonKey(name: 'jobTitle')
  final String? jobTitle;

  // Relationships - oft als separate API calls geladen
  @JsonKey(includeFromJson: false, includeToJson: false)
  final List<Certificate>? certificates;

  const User({
    this.id,
    required this.username,
    required this.email,
    this.password,
    this.role = UserRole.user,
    this.enabled = true,
    this.firstName,
    this.lastName,
    this.organization,
    this.jobTitle,
    this.certificates,
  });

  // JSON Serialization
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  // Convenience methods
  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();

  String get displayName => fullName.isNotEmpty ? fullName : username;

  List<Certificate> get activeCertificates {
    return certificates?.where((cert) => cert.isActive).toList() ?? [];
  }

  bool hasActiveCertificateOfType(CertificateType type) {
    return activeCertificates.any((cert) => cert.type == type);
  }

  bool canAccessDatasource(Dataset datasource) {
    // Public datasources are accessible to everyone
    if (datasource.accessLevel == AccessLevel.public) {
      return true;
    }

    // No certificates required
    if (!datasource.requiresCertificate || datasource.requiredCertificateTypes.isEmpty) {
      return true;
    }

    // Check if user has one of the required certificates
    return datasource.requiredCertificateTypes.any((type) => hasActiveCertificateOfType(type));
  }

  // Copy method for immutability
  User copyWith({
    int? id,
    String? username,
    String? email,
    String? password,
    UserRole? role,
    bool? enabled,
    String? firstName,
    String? lastName,
    String? organization,
    String? jobTitle,
    List<Certificate>? certificates,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      enabled: enabled ?? this.enabled,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      organization: organization ?? this.organization,
      jobTitle: jobTitle ?? this.jobTitle,
      certificates: certificates ?? this.certificates,
    );
  }
}

enum UserRole {
  @JsonValue('USER')
  user('USER', 'Nutzer'),

  @JsonValue('ADMIN')
  admin('ADMIN', 'Administrator'),

  @JsonValue('DATA_PROVIDER')
  dataProvider('DATA_PROVIDER', 'Datenanbieter'),

  @JsonValue('REVIEWER')
  reviewer('REVIEWER', 'Zertifikatsprüfer');

  const UserRole(this.value, this.displayName);

  final String value;
  final String displayName;

  factory UserRole.fromJson(String json) => values.firstWhere(
    (role) => role.value == json,
    orElse: () => UserRole.user,
  );

  String toJson() => value;
}
