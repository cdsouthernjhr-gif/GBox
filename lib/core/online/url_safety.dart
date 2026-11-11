/// URL and file-name safety rules for the Online Source Manager.
library;

import '../rom/scan_planner.dart' show imageExtensions;
import '../rom/title_normalizer.dart';

class UrlCheck {
  const UrlCheck._(this.uri, this.error);
  const UrlCheck.ok(Uri uri) : this._(uri, null);
  const UrlCheck.bad(String error) : this._(null, error);
  final Uri? uri;
  final String? error;
  bool get ok => error == null;
}

/// Validates a user-supplied source or download URL.
///
/// * HTTPS only (certificates are verified by the platform; GAMEBOX never
///   disables verification). [allowHttp] exists for tests against a local
///   server only.
/// * No embedded credentials (`user:pass@host`) — GAMEBOX does not handle
///   authentication in this phase and never bypasses it.
/// * No control characters, sane length, a real host.
UrlCheck validateUrl(String input, {bool allowHttp = false}) {
  final s = input.trim();
  if (s.isEmpty) return const UrlCheck.bad('Enter a URL');
  if (s.length > 2048) return const UrlCheck.bad('URL is too long');
  if (RegExp(r'[\x00-\x1F\x7F\s]').hasMatch(s)) {
    return const UrlCheck.bad('URL contains spaces or control characters');
  }
  final uri = Uri.tryParse(s);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) return const UrlCheck.bad('Not a valid web address');
  final scheme = uri.scheme.toLowerCase();
  if (scheme != 'https' && !(allowHttp && scheme == 'http')) {
    return const UrlCheck.bad('Only secure https:// addresses are allowed');
  }
  if (uri.userInfo.isNotEmpty) {
    return const UrlCheck.bad('Addresses with a user name or password are not supported');
  }
  return UrlCheck.ok(uri);
}

/// A redirect is followed only if the target is itself valid and does not
/// downgrade from https to http.
UrlCheck validateRedirect(Uri from, Uri to, {bool allowHttp = false}) {
  final check = validateUrl(to.toString(), allowHttp: allowHttp);
  if (!check.ok) return check;
  if (from.scheme == 'https' && to.scheme != 'https') {
    return const UrlCheck.bad('Redirect from https to an insecure address was blocked');
  }
  return check;
}

/// File types GAMEBOX will download: game files, archives, images, and the
/// catalogue JSON. Executables/installers are refused; nothing downloaded is
/// ever executed.
Set<String> downloadableExtensions(Set<String> romExtensions) =>
    {...romExtensions, 'zip', '7z', ...imageExtensions, 'json'};

const blockedExtensions = {'apk', 'apks', 'xapk', 'exe', 'msi', 'bat', 'cmd', 'sh', 'so', 'dex', 'jar', 'js'};

/// File name from `Content-Disposition` (RFC 6266 `filename`/`filename*`).
String? filenameFromContentDisposition(String? header) {
  if (header == null) return null;
  final star = RegExp(r"filename\*\s*=\s*(?:UTF-8|utf-8)''([^;]+)").firstMatch(header);
  if (star != null) {
    try {
      return Uri.decodeComponent(star.group(1)!.trim());
    } catch (_) {}
  }
  final plain = RegExp(r'filename\s*=\s*"([^"]*)"|filename\s*=\s*([^;]+)').firstMatch(header);
  final v = plain?.group(1) ?? plain?.group(2);
  return v?.trim();
}

/// Makes a safe single-component file name: no directories, no `..`, no
/// reserved characters, limited length, extension preserved.
String sanitizeFileName(String raw, {String fallback = 'download'}) {
  var name = raw.replaceAll('\\', '/').split('/').last;
  name = name.replaceAll(RegExp(r'[\x00-\x1F\x7F<>:"|?*]'), '_').trim();
  name = name.replaceAll(RegExp(r'^\.+'), ''); // no hidden/dot names
  if (name.isEmpty || name == '.' || name == '..') name = fallback;
  if (name.length > 120) {
    final ext = extensionOf(name);
    final keep = 120 - (ext.isEmpty ? 0 : ext.length + 1);
    name = ext.isEmpty ? name.substring(0, keep) : '${name.substring(0, keep)}.$ext';
  }
  return name;
}

String fileNameForUrl(Uri uri, {String? contentDisposition}) {
  final fromHeader = filenameFromContentDisposition(contentDisposition);
  final fromPath = uri.pathSegments.where((s) => s.isNotEmpty).lastOrNull;
  return sanitizeFileName(fromHeader ?? fromPath ?? 'download');
}
