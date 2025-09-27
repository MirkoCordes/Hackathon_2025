import 'package:flutter_frontend/feature/certificate/certificate_upload.state.dart';
import 'package:flutter_frontend/feature/user/certificate.entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'certificate_upload.controller.g.dart';

@riverpod
class CertificateUploadController extends _$CertificateUploadController {
  /// Die 'build'-Methode muss den initialen Zustand des Providers zurückgeben.
  @override
  CertificateUploadState build() {
    return CertificateUploadState(popOnSuccess: false);
  }

  Future<void> updateStates({
    required bool popOnSuccess,
    List<CertificateType>? availableTypes,
  }) async {
    state = CertificateUploadState(
      popOnSuccess: popOnSuccess,
      availableTypes: availableTypes,
    );
  }

  /*
  Future<void> search(String query) async {
    final CatalogRepository catalogRepository = CatalogRepository();
    final CatalogResponse response = await catalogRepository.getCatalogs(query);
    state = CatalogState(searchQuery: query, datasets: response.datasources);
  }

  */
}
