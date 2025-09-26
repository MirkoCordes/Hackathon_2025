// Conditional import - picks web implementation when available, otherwise a noop
import 'browser_download_none.dart' if (dart.library.html) 'browser_download_web.dart';

// Re-export the function for easier imports
export 'browser_download_none.dart' if (dart.library.html) 'browser_download_web.dart';
