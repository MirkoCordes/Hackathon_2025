import 'package:flutter_frontend/feature/user/certificate.entity.dart';
import 'package:flutter_frontend/feature/user/certificate.repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'certificate.controller.g.dart';

@riverpod
class CertificateListController extends _$CertificateListController {
  @override
  Future<List<Certificate>> build() {
    return CertificateRepository().getMyCertificates();
  }
}

@riverpod
class CertificateTypesController extends _$CertificateTypesController {
  @override
  Future<List<CertificateType>> build() {
    return CertificateRepository().getTypes();
  }
}
