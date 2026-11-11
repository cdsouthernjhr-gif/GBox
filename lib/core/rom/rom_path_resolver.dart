/// Resolves library file references to forms external emulators accept.
///
/// * Plain paths are returned as-is.
/// * Storage Access Framework URIs from Android's ExternalStorageProvider
///   (`content://com.android.externalstorage.documents/…/document/<id>`)
///   encode the volume and relative path in the document id:
///   `primary:ROMs/NES/x.nes` → `/storage/emulated/0/ROMs/NES/x.nes`,
///   `ABCD-1234:ROMs/x.nes` → `/storage/ABCD-1234/ROMs/x.nes`.
/// * Other providers (Downloads, cloud, media) expose no path → null.
library;

const externalStorageAuthority = 'com.android.externalstorage.documents';

String? resolveFilesystemPath(String uriOrPath) {
  if (!uriOrPath.startsWith('content://')) return uriOrPath;
  final uri = Uri.tryParse(uriOrPath);
  if (uri == null || uri.host != externalStorageAuthority) return null;
  final segs = uri.pathSegments;
  final docIdx = segs.indexOf('document');
  if (docIdx < 0 || docIdx + 1 >= segs.length) return null;
  // pathSegments are already percent-decoded.
  final docId = segs[docIdx + 1];
  final colon = docId.indexOf(':');
  if (colon <= 0) return null;
  final volume = docId.substring(0, colon);
  final rel = docId.substring(colon + 1);
  if (rel.contains('..')) return null;
  final base = volume == 'primary' ? '/storage/emulated/0' : (volume == 'home' ? '/storage/emulated/0/Documents' : '/storage/$volume');
  return rel.isEmpty ? base : '$base/$rel';
}

/// True when [path] is inside an app-specific directory (`…/Android/data/`
/// or `…/Android/obb/`). From Android 11 (API 30) other apps — including
/// emulators — cannot read these paths.
bool isAppPrivateExternalPath(String path) =>
    RegExp(r'/Android/(data|obb)/', caseSensitive: false).hasMatch(path);
