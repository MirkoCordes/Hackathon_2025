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
    if (resp.statusCode != 200) {
      throw Exception('upload failed: ${resp.statusCode} ${resp.body}');
    }
  }
}
