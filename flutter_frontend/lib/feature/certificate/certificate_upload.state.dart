import 'package:flutter_frontend/feature/user/certificate.entity.dart';

class CertificateUploadState {
  final bool popOnSuccess;
  final List<CertificateType>? availableTypes;

  const CertificateUploadState({
    required this.popOnSuccess,
    this.availableTypes,
  });
}
