import 'package:flutter_frontend/feature/user/user.entity.dart';
import 'package:flutter_frontend/feature/user/user.repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user.controller.g.dart';

@riverpod
class UserController extends _$UserController {
  @override
  Future<User> build() {
    return UserRepository().getCurrent();
  }
}
