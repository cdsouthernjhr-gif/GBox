/// HTTPS download engine: safe redirects, resume, size/space/hash checks.
///
/// * TLS certificates are verified by `dart:io` (never disabled).
/// * Redirects are followed manually (max 5); each target is re-validated and
///   https→http downgrades are refused.
/// * HTML pages are refused: GAMEBOX downloads files, it does not scrape.
/// * Executables/installers are refused; downloads are never executed.
/// * Resume uses HTTP `Range`; a server without range support restarts.
/// * SHA-256 is computed while streaming and compared when expected.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

import '../rom/title_normalizer.dart';
import 'url_safety.dart';

const userAgent = 'GAMEBOX/0.5 (Android TV game launcher)';

enum StopReason { pause, cancel }

class CancelToken {
  StopReason? _reason;
  final _completer = Completer<void>();
  StopReason? get reason => _reason;
  bool get isStopped => _reason != null;
  Future<void> get whenStopped => _completer.future;

  void stop(StopReason r) {
    if (_reason != null) return;
    _reason = r;
    _completer.complete();
  }
}

class DownloadProgress {
  const DownloadProgress({required this.received, this.total, this.bytesPerSecond = 0});
  final int received;
  final int? total;
  final double bytesPerSecond;

  Duration? get eta {
    final t = total;
    if (t == null || bytesPerSecond <= 1) return null;
    return Duration(seconds: ((t - received) / bytesPerSecond).ceil());
  }

  double? get fraction => total == null || total == 0 ? null : (received / total!).clamp(0.0, 1.0);
}

enum OutcomeKind { completed, paused, cancelled, failed, networkError }

class DownloadOutcome {
  const DownloadOutcome(this.kind, {this.path, this.size, this.sha256, this.error, this.resolvedName});
  final OutcomeKind kind;
  final String? path;
  final int? size;
  final String? sha256;
  final String? error;
  final String? resolvedName;
  bool get ok => kind == OutcomeKind.completed;
}

class DownloadRequest {
  const DownloadRequest({
    required this.url,
    required this.destDir,
    required this.allowedExtensions,
    this.destinationPath,
    this.expectedSha256,
    this.expectedSize,
    this.maxBytes = 8 * 1024 * 1024 * 1024,
  });

  final Uri url;
  final String destDir;

  /// Known when resuming (the `.part` file is `<destinationPath>.part`).
  final String? destinationPath;
  final Set<String> allowedExtensions;
  final String? expectedSha256;
  final int? expectedSize;
  final int maxBytes;
}

class ProbeResult {
  const ProbeResult({this.statusCode, this.contentType, this.size, this.finalUrl, this.error});
  final int? statusCode;
  final String? contentType;
  final int? size;
  final Uri? finalUrl;
  final String? error;
  bool get ok => error == null && statusCode != null && statusCode! < 400;
}

class _Fail implements Exception {
  _Fail(this.message, {this.network = false});
  final String message;
  final bool network;
}

class DownloadEngine {
  DownloadEngine({this.allowHttp = false, this.freeSpace, HttpClient Function()? clientFactory})
      : _clientFactory = clientFactory ?? HttpClient.new;

  /// Accept http:// (tests against a local server).
  final bool allowHttp;

  /// The user's "Allow http:// downloads" setting: accepts http:// URLs and
  /// https → http redirects. Off by default.
  bool userAllowsHttp = false;

  /// Whether http:// addresses are accepted right now.
  bool get httpAllowed => allowHttp || userAllowsHttp;

  /// Free bytes at a directory, or null if unknown.
  final Future<int?> Function(String dir)? freeSpace;
  final HttpClient Function() _clientFactory;

  static const _maxRedirects = 5;
  static const _idleTimeout = Duration(seconds: 30);
  static const _spaceMargin = 50 * 1024 * 1024;

  HttpClient _client() => _clientFactory()
    ..connectionTimeout = const Duration(seconds: 20)
    ..userAgent = userAgent
    ..autoUncompress = false;

  /// Opens [url] following safe redirects. Returns the final response.
  Future<(HttpClientResponse, Uri)> _open(HttpClient client, Uri url, String method,
      {Map<String, String> headers = const {}}) async {
    var current = url;
    for (var i = 0; i <= _maxRedirects; i++) {
      final req = await client.openUrl(method, current);
      req.followRedirects = false;
      headers.forEach(req.headers.set);
      final res = await req.close();
      if (res.isRedirect) {
        final loc = res.headers.value(HttpHeaders.locationHeader);
        await res.drain<void>().catchError((_) {});
        if (loc == null) throw _Fail('Redirect without a target');
        final next = current.resolve(loc);
        final check = validateRedirect(current, next, allowHttp: allowHttp, allowDowngrade: userAllowsHttp);
        if (!check.ok) throw _Fail(check.error!);
        current = next;
        continue;
      }
      return (res, current);
    }
    throw _Fail('Too many redirects');
  }

  /// HEAD (falling back to a 1-byte GET) to check that a source answers.
  Future<ProbeResult> probe(Uri url) async {
    final check = validateUrl(url.toString(), allowHttp: httpAllowed);
    if (!check.ok) return ProbeResult(error: check.error);
    final client = _client();
    try {
      var (res, finalUrl) = await _open(client, url, 'HEAD');
      if (res.statusCode == 405 || res.statusCode == 501) {
        await res.drain<void>().catchError((_) {});
        (res, finalUrl) = await _open(client, url, 'GET', headers: {'Range': 'bytes=0-0'});
      }
      await res.drain<void>().catchError((_) {});
      return ProbeResult(
        statusCode: res.statusCode,
        contentType: res.headers.contentType?.mimeType,
        size: res.contentLength >= 0 ? res.contentLength : null,
        finalUrl: finalUrl,
      );
    } on _Fail catch (e) {
      return ProbeResult(error: e.message);
    } on HandshakeException catch (e) {
      return ProbeResult(error: 'Secure connection failed (certificate not trusted): ${e.message}');
    } catch (e) {
      return ProbeResult(error: 'Could not connect: $e');
    } finally {
      client.close(force: true);
    }
  }

  /// Downloads a small text document (e.g. a catalogue), max [maxBytes].
  Future<String> fetchText(Uri url, {int maxBytes = 2 * 1024 * 1024}) async {
    final check = validateUrl(url.toString(), allowHttp: httpAllowed);
    if (!check.ok) throw _Fail(check.error!);
    final client = _client();
    try {
      final (res, _) = await _open(client, url, 'GET');
      if (res.statusCode != 200) throw _Fail('Server answered HTTP ${res.statusCode}');
      if (res.contentLength > maxBytes) throw _Fail('Document too large');
      final bytes = <int>[];
      await for (final chunk in res.timeout(_idleTimeout)) {
        bytes.addAll(chunk);
        if (bytes.length > maxBytes) throw _Fail('Document too large');
      }
      return utf8.decode(bytes, allowMalformed: true);
    } finally {
      client.close(force: true);
    }
  }

  Future<DownloadOutcome> download(
    DownloadRequest r, {
    void Function(DownloadProgress)? onProgress,
    void Function(String destinationPath)? onDestination,
    CancelToken? token,
  }) async {
    final check = validateUrl(r.url.toString(), allowHttp: httpAllowed);
    if (!check.ok) return DownloadOutcome(OutcomeKind.failed, error: check.error);
    token ??= CancelToken();
    final client = _client();
    final stopSub = token.whenStopped.then((_) => client.close(force: true));
    String? dest = r.destinationPath;
    File? part;
    IOSink? sink;
    try {
      var existing = 0;
      if (dest != null) {
        part = File('$dest.part');
        if (await part.exists()) existing = await part.length();
      }
      final (res, finalUrl) = await _open(
        client,
        r.url,
        'GET',
        headers: {if (existing > 0) 'Range': 'bytes=$existing-'},
      );
      if (res.statusCode == 416 && existing > 0) {
        // Nothing left to fetch; validate what we have.
        await res.drain<void>().catchError((_) {});
      } else if (res.statusCode != 200 && res.statusCode != 206) {
        await res.drain<void>().catchError((_) {});
        throw _Fail('Server answered HTTP ${res.statusCode}', network: res.statusCode >= 500);
      }
      final mime = res.headers.contentType?.mimeType ?? '';
      if (mime == 'text/html' || mime == 'application/xhtml+xml') {
        await res.drain<void>().catchError((_) {});
        throw _Fail('This address is a web page, not a file. GAMEBOX downloads direct file links only '
            'and does not scrape websites.');
      }

      // Destination name (first attempt only).
      if (dest == null) {
        final name = fileNameForUrl(finalUrl,
            contentDisposition: res.headers.value('content-disposition'));
        final ext = extensionOf(name);
        if (blockedExtensions.contains(ext)) {
          await res.drain<void>().catchError((_) {});
          throw _Fail('".$ext" files are not allowed. GAMEBOX never downloads apps or executables.');
        }
        if (!r.allowedExtensions.contains(ext)) {
          await res.drain<void>().catchError((_) {});
          throw _Fail('"$name" is not a supported game, archive or image file.');
        }
        dest = await _uniquePath(r.destDir, name);
        onDestination?.call(dest);
        part = File('$dest.part');
        existing = 0;
      }

      final resumed = res.statusCode == 206 && existing > 0;
      if (!resumed && res.statusCode != 416) existing = 0; // server restarted from 0
      final len = res.contentLength >= 0 ? res.contentLength : null;
      final total = res.statusCode == 416 ? existing : (len == null ? null : existing + len);
      if (total != null && total > r.maxBytes) {
        await res.drain<void>().catchError((_) {});
        throw _Fail('File is larger than the allowed maximum');
      }
      if (r.expectedSize != null && total != null && total != r.expectedSize) {
        await res.drain<void>().catchError((_) {});
        throw _Fail('Server reports ${total}B but ${r.expectedSize}B were expected');
      }
      if (total != null && freeSpace != null) {
        final free = await freeSpace!(r.destDir);
        if (free != null && total - existing > free - _spaceMargin) {
          await res.drain<void>().catchError((_) {});
          throw _Fail('Not enough free storage space');
        }
      }

      // Hash: feed already-downloaded bytes first when resuming.
      final digestSink = _DigestSink();
      final hasher = sha256.startChunkedConversion(digestSink);
      await part!.parent.create(recursive: true);
      if (existing > 0) {
        await for (final c in part.openRead()) {
          hasher.add(c);
        }
        sink = part.openWrite(mode: FileMode.append);
      } else {
        sink = part.openWrite(mode: FileMode.write);
      }

      var received = existing;
      final started = DateTime.now();
      var lastTick = started;
      var lastBytes = received;
      var speed = 0.0;
      if (res.statusCode != 416) {
        await for (final chunk in res.timeout(_idleTimeout)) {
          if (token.isStopped) break;
          sink.add(chunk);
          hasher.add(chunk);
          received += chunk.length;
          if (received > r.maxBytes) throw _Fail('File is larger than the allowed maximum');
          final now = DateTime.now();
          final dt = now.difference(lastTick).inMilliseconds;
          if (dt >= 500) {
            final inst = (received - lastBytes) * 1000 / dt;
            speed = speed == 0 ? inst : speed * 0.7 + inst * 0.3;
            lastTick = now;
            lastBytes = received;
            onProgress?.call(DownloadProgress(received: received, total: total, bytesPerSecond: speed));
          }
        }
      }
      await sink.flush();
      await sink.close();
      sink = null;

      if (token.isStopped) {
        if (token.reason == StopReason.cancel) await _delete(part);
        return DownloadOutcome(token.reason == StopReason.cancel ? OutcomeKind.cancelled : OutcomeKind.paused,
            path: dest);
      }
      onProgress?.call(DownloadProgress(received: received, total: total, bytesPerSecond: speed));
      if (total != null && received != total) {
        return DownloadOutcome(OutcomeKind.networkError,
            path: dest, error: 'Connection ended early ($received of $total bytes); will resume');
      }
      hasher.close();
      final digest = digestSink.value.toString();
      if (r.expectedSha256 != null && digest != r.expectedSha256!.toLowerCase()) {
        await _delete(part);
        return DownloadOutcome(OutcomeKind.failed,
            path: dest, error: 'Integrity check failed (SHA-256 mismatch). The file was deleted.');
      }
      if (r.expectedSize != null && received != r.expectedSize) {
        await _delete(part);
        return DownloadOutcome(OutcomeKind.failed, path: dest, error: 'Size mismatch. The file was deleted.');
      }
      final finalFile = await part.rename(dest);
      return DownloadOutcome(OutcomeKind.completed,
          path: finalFile.path, size: received, sha256: digest, resolvedName: finalFile.uri.pathSegments.last);
    } on _Fail catch (e) {
      if (token.isStopped) return _stopped(token, part, dest);
      return DownloadOutcome(e.network ? OutcomeKind.networkError : OutcomeKind.failed, path: dest, error: e.message);
    } on HandshakeException catch (e) {
      return DownloadOutcome(OutcomeKind.failed, path: dest, error: 'Secure connection failed: ${e.message}');
    } on TimeoutException {
      return DownloadOutcome(OutcomeKind.networkError, path: dest, error: 'Connection timed out; will retry');
    } on IOException catch (e) {
      if (token.isStopped) return _stopped(token, part, dest);
      return DownloadOutcome(OutcomeKind.networkError, path: dest, error: 'Network error: $e');
    } catch (e) {
      if (token.isStopped) return _stopped(token, part, dest);
      return DownloadOutcome(OutcomeKind.failed, path: dest, error: '$e');
    } finally {
      await sink?.close().catchError((_) {});
      client.close(force: true);
      unawaited(stopSub);
    }
  }

  Future<DownloadOutcome> _stopped(CancelToken t, File? part, String? dest) async {
    if (t.reason == StopReason.cancel && part != null) await _delete(part);
    return DownloadOutcome(t.reason == StopReason.cancel ? OutcomeKind.cancelled : OutcomeKind.paused, path: dest);
  }

  static Future<void> _delete(File f) async {
    try {
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }

  static Future<String> _uniquePath(String dir, String name) async {
    await Directory(dir).create(recursive: true);
    final base = stripExtension(name);
    final ext = extensionOf(name);
    var candidate = '$dir/$name';
    for (var i = 1; await File(candidate).exists() || await File('$candidate.part').exists(); i++) {
      candidate = '$dir/$base ($i)${ext.isEmpty ? '' : '.$ext'}';
    }
    return candidate;
  }
}

class _DigestSink implements Sink<Digest> {
  late Digest value;
  @override
  void add(Digest data) => value = data;
  @override
  void close() {}
}
