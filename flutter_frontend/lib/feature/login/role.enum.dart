import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum Role {
  @JsonValue('ADMIN')
  admin,

  @JsonValue('USER')
  user,

  @JsonValue('DATA_PROVIDER')
  dataProvider,
}
