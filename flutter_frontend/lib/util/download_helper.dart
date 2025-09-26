import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

/// Save bytes to a temporary file and open it. On web this method is not used.
Future<void> saveAndOpenFile(Uint8List bytes, String filename) async {
  if (kIsWeb) {
    throw UnsupportedError('Use web download logic for browser');
  }

  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$filename');
  await file.writeAsBytes(bytes);
  await OpenFile.open(file.path);
}
