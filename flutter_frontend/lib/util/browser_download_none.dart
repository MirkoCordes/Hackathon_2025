import 'dart:typed_data';

void triggerBrowserDownload(Uint8List bytes, String filename, {String? mimeType}) {
  // keep parameters referenced to avoid analyzer 'unused parameter' errors
  throw UnsupportedError(
    'Browser download not supported on this platform: $filename, mime=${mimeType ?? "(none)"}, size=${bytes.length}',
  );
}

void openInNewTab(Uint8List bytes, {String? mimeType}) {
  throw UnsupportedError('openInNewTab is only supported on web. size=${bytes.length}, mime=${mimeType ?? "(none)"}');
}
