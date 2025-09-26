import 'package:flutter_frontend/feature/user/certificate.entity.dart';
import 'package:flutter_frontend/feature/user/certificate.repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'certificate_admin.controller.g.dart';

@riverpod
class PendingCertificatesController extends _$PendingCertificatesController {
  @override
  Future<List<Certificate>> build() {
    return CertificateRepository().getPendingCertificates();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => CertificateRepository().getPendingCertificates());
  }
}
