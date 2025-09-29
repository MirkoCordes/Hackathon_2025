import 'dart:convert';
import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:flutter_frontend/feature/user/certificate.entity.dart';
import 'package:flutter_frontend/jwt.repository.dart';
import 'package:http/http.dart' as http;

class CertificateRepository {
  static const String baseUrl = 'http://localhost:8080/api/certificates';

  Future<List<Certificate>> getMyCertificates() async {
    final String? jwt = await JwtRepository().getJwt();
    if (jwt == null) return Future.error('no jwt');

    final response = await http.get(
      Uri.parse('$baseUrl/my'),
      headers: {'Authorization': 'Bearer $jwt'},
    );

    if (response.statusCode == 200) {
      final String utf8Decodes = utf8.decode(response.bodyBytes);
      final List<dynamic> list = json.decode(utf8Decodes);
      return list.map((e) => Certificate.fromJson(e)).toList();
    }
    throw Exception('failed to load certificates');
  }

  Future<List<CertificateType>> getTypes() async {
    final String? jwt = await JwtRepository().getJwt();
    if (jwt == null) return Future.error('no jwt');
    final response = await http.get(
      Uri.parse('$baseUrl/types'),
      headers: {'Authorization': 'Bearer $jwt'},
    );
    if (response.statusCode == 200) {
      final String utf8Decodes = utf8.decode(response.bodyBytes);
      final List<dynamic> list = json.decode(utf8Decodes);
      return list.map((e) => CertificateType.fromJson(e as String)).toList();
    } else {
      debugPrint('Error fetching: ${response.statusCode} ${response.body}'); // Debug-Ausgabe
    }
    throw Exception('failed to load types');
  }

  /// Upload a certificate. Either provide [file] (native platforms) or [bytes]+[filename] (web).
  Future<void> upload({
    required CertificateType type,
    required String description,
    File? file,
    List<int>? bytes,
    String? filename,
    DateTime? validUntil,
  }) async {
    final String? jwt = await JwtRepository().getJwt();
    if (jwt == null) return Future.error('no jwt');

    final uri = Uri.parse('$baseUrl/upload');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $jwt';
    request.fields['type'] = type.toJson();
    request.fields['description'] = description;
    if (validUntil != null) {
      // format as YYYY-MM-DD
      request.fields['validUntil'] = validUntil.toIso8601String().substring(0, 10);
    }

    if (bytes != null && filename != null) {
      final multipartFile = http.MultipartFile.fromBytes('file', bytes, filename: filename);
      request.files.add(multipartFile);
    } else {
      throw Exception('No file data provided for upload');
    }

    final streamed = await request.send();
    final resp = await http.Response.fromStream(streamed);
    debugPrint('Upload response: ${resp.statusCode} ${resp.body}');
    if (resp.statusCode != 200) {
      throw Exception('upload failed: ${resp.statusCode} ${resp.body}');
    }
  }

  Future<List<Certificate>> getPendingCertificates() async {
    final String? jwt = await JwtRepository().getJwt();
    if (jwt == null) return Future.error('no jwt');

    final response = await http.get(
      Uri.parse('$baseUrl/pending'),
      headers: {'Authorization': 'Bearer $jwt'},
    );

    if (response.statusCode == 200) {
      final String utf8Decodes = utf8.decode(response.bodyBytes);
      final List<dynamic> list = json.decode(utf8Decodes);
      return list.map((e) => Certificate.fromJson(e)).toList();
    }
    throw Exception('failed to load pending certificates');
  }

  Future<void> reviewCertificate(int id, String status, {String? notes}) async {
    final String? jwt = await JwtRepository().getJwt();
    if (jwt == null) return Future.error('no jwt');

    final uri = Uri.parse(
      '$baseUrl/$id/review?status=$status${notes != null ? '&reviewNotes=${Uri.encodeComponent(notes)}' : ''}',
    );
    final resp = await http.post(uri, headers: {'Authorization': 'Bearer $jwt'});
    if (resp.statusCode != 200) {
      throw Exception('review failed: ${resp.statusCode} ${resp.body}');
    }
  }

  /// Download file bytes for a certificate id
  Future<DownloadResult> downloadCertificateFile(int id) async {
    final String? jwt = await JwtRepository().getJwt();
    if (jwt == null) return Future.error('no jwt');

    final response = await http.get(
      Uri.parse('$baseUrl/$id/file'),
      headers: {'Authorization': 'Bearer $jwt'},
    );

    if (response.statusCode == 200) {
      // Try to extract filename from Content-Disposition
      String? filename;
      final cd = response.headers['content-disposition'];
      if (cd != null) {
        // filename*=UTF-8''... or filename="..."
        final filenameStar = RegExp(r"filename\*=[^']*'[^']*'(?<name>.+)", caseSensitive: false).firstMatch(cd);
        if (filenameStar != null) {
          filename = Uri.decodeFull(filenameStar.namedGroup('name') ?? '');
        } else {
          final filenameMatch = RegExp(r'filename="(?<name>[^"]+)"', caseSensitive: false).firstMatch(cd);
          if (filenameMatch != null) filename = filenameMatch.namedGroup('name');
        }
      }

      final mime = response.headers['content-type'];
      return DownloadResult(bytes: response.bodyBytes, filename: filename, mimeType: mime);
    }
    throw Exception('failed to download file: ${response.statusCode}');
  }
}

class DownloadResult {
  final List<int> bytes;
  final String? filename;
  final String? mimeType;

  const DownloadResult({required this.bytes, this.filename, this.mimeType});
}
