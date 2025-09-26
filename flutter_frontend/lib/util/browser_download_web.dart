import 'dart:html' as html;
import 'dart:typed_data';

void triggerBrowserDownload(Uint8List bytes, String filename, {String? mimeType}) {
  final blob = html.Blob([bytes], mimeType ?? 'application/octet-stream');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.document.createElement('a') as html.AnchorElement;
  anchor.href = url;
  anchor.download = filename;
  anchor.style.display = 'none';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
}

/// Open bytes in a new browser tab (useful for images/PDF preview)
void openInNewTab(Uint8List bytes, {String? mimeType}) {
  final blob = html.Blob([bytes], mimeType ?? 'application/octet-stream');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.window.open(url, '_blank');
  // revoke later to allow the new tab to load
  Future.delayed(const Duration(seconds: 2), () => html.Url.revokeObjectUrl(url));
}
