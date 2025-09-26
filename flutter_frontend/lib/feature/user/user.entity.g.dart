// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num?)?.toInt(),
  username: json['username'] as String,
  email: json['email'] as String,
  role:
      json['role'] == null
          ? UserRole.user
          : UserRole.fromJson(json['role'] as String),
  enabled: json['enabled'] as bool? ?? true,
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  organization: json['organization'] as String?,
  jobTitle: json['jobTitle'] as String?,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'email': instance.email,
  'role': instance.role,
  'enabled': instance.enabled,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'organization': instance.organization,
  'jobTitle': instance.jobTitle,
};
