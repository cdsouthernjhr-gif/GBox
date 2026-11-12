import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamebox/core/online/archive_guard.dart';
import 'package:gamebox/core/online/catalog.dart';
import 'package:gamebox/core/online/download_engine.dart';
import 'package:gamebox/core/online/url_safety.dart';

/// Deterministic test payload (not game data).
Uint8List payload(int n) => Uint8List.fromList(List.generate(n, (i) => (i * 31 + 7) & 0xFF));

/// Minimal local server used by the engine tests.
class TestServer {
  late HttpServer server;
  final files = <String, Uint8List>{};
  int requests = 0;
  final rangeRequests = <String>[];
  Completer<void>? slowGate;

  Uri url(String path) => Uri.parse('http://127.0.0.1:${server.port}$path');

  Future<void> start() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen(_handle);
  }

  Future<void> _handle(HttpRequest req) async {
    requests++;
    final res = req.response;
    // Stream like a real server (Dart's HttpServer buffers output by default).
    res.bufferOutput = false;
    final path = req.uri.path;
    switch (path) {
      case '/redirect':
        res.statusCode = 302;
        res.headers.set('location', '/game.nes');
        return res.close();
      case '/loop':
        res.statusCode = 302;
        res.headers.set('location', '/loop');
        return res.close();
      case '/to-ftp':
        res.statusCode = 302;
        res.headers.set('location', 'ftp://example.org/x.nes');
        return res.close();
      case '/page':
        res.headers.contentType = ContentType.html;
        res.write('<html>hi</html>');
        return res.close();
      case '/short.gba':
        // Claims 1000 bytes, sends 400, then drops the connection.
        res.headers.contentLength = 1000;
        final socket = await res.detachSocket(); // writes the headers
        socket.add(payload(400));
        await socket.flush();
        socket.destroy();
        return;
      case '/disposition':
        res.headers.set('content-disposition', 'attachment; filename="../../evil name.gb"');
        res.add(payload(64));
        return res.close();
    }
    final data = files[path];
    if (data == null) {
      res.statusCode = 404;
      return res.close();
    }
    final range = req.headers.value('range');
    final supportsRange = !path.contains('norange');
    var start = 0;
    if (range != null && supportsRange) {
      rangeRequests.add(range);
      start = int.parse(RegExp(r'bytes=(\d+)-').firstMatch(range)!.group(1)!);
      if (start >= data.length) {
        res.statusCode = 416;
        return res.close();
      }
      res.statusCode = 206;
      res.headers.set('content-range', 'bytes $start-${data.length - 1}/${data.length}');
    }
    res.headers.contentType = ContentType.binary;
    res.headers.contentLength = data.length - start;
    if (path.contains('slow')) {
      // Send in chunks, waiting on the gate after the first one.
      for (var i = start; i < data.length; i += 1024) {
        res.add(data.sublist(i, (i + 1024).clamp(0, data.length)));
        await res.flush();
        if (slowGate != null && i == start) await slowGate!.future;
      }
      return res.close();
    }
    res.add(data.sublist(start));
    return res.close();
  }
}

Uint8List zipOf(Map<String, List<int>> files, {Map<String, String> symlinks = const {}}) {
  final a = Archive();
  files.forEach((n, d) => a.add(ArchiveFile.bytes(n, d)));
  symlinks.forEach((n, target) => a.add(ArchiveFile.symlink(n, target)));
  return Uint8List.fromList(ZipEncoder().encode(a));
}

void main() {
  group('URL safety', () {
    test('https only, no credentials, no whitespace', () {
      expect(validateUrl('https://example.org/a.nes').ok, isTrue);
      expect(validateUrl('http://example.org/a.nes').error, contains('https'));
      expect(validateUrl('ftp://example.org/a').ok, isFalse);
      expect(validateUrl('https://user:pw@example.org/a').ok, isFalse);
      expect(validateUrl('https://exa mple.org').ok, isFalse);
      expect(validateUrl('').ok, isFalse);
      expect(validateUrl('javascript:alert(1)').ok, isFalse);
    });

    test('redirect downgrade is blocked', () {
      final from = Uri.parse('https://a.org/x');
      expect(validateRedirect(from, Uri.parse('https://b.org/y')).ok, isTrue);
      expect(validateRedirect(from, Uri.parse('http://b.org/y'), allowHttp: true).ok, isFalse);
      // Only when the user allowed http:// downloads.
      expect(validateRedirect(from, Uri.parse('http://b.org/y'), allowDowngrade: true).ok, isTrue);
    });

    test('http:// only when the user allows it', () {
      final e = DownloadEngine();
      expect(e.httpAllowed, isFalse);
      expect(validateUrl('http://a.org/x.nes', allowHttp: e.httpAllowed).ok, isFalse);
      e.userAllowsHttp = true;
      expect(validateUrl('http://a.org/x.nes', allowHttp: e.httpAllowed).ok, isTrue);
    });

    test('file names are sanitised', () {
      expect(sanitizeFileName('../../etc/passwd'), 'passwd');
      expect(sanitizeFileName('..'), 'download');
      expect(sanitizeFileName('a<b>c:d.nes'), 'a_b_c_d.nes');
      expect(sanitizeFileName('.hidden.gba'), 'hidden.gba');
      expect(sanitizeFileName('${'x' * 300}.sfc').length, 120);
      expect(sanitizeFileName('${'x' * 300}.sfc'), endsWith('.sfc'));
      expect(filenameFromContentDisposition("attachment; filename*=UTF-8''Caf%C3%A9.nes"), 'Café.nes');
      expect(filenameFromContentDisposition('attachment; filename="a b.gb"'), 'a b.gb');
    });
  });

  group('catalogue', () {
    final good = {
      'format': 'gamebox-catalog',
      'version': 1,
      'name': 'Test Homebrew',
      'games': [
        {'title': 'Ok', 'console': 'nes', 'url': 'https://h.org/ok.nes', 'license': 'CC0-1.0', 'size': 10},
        {'title': 'NoLicence', 'console': 'nes', 'url': 'https://h.org/x.nes'},
        {'title': 'Insecure', 'console': 'nes', 'url': 'http://h.org/x.nes', 'license': 'MIT'},
        {'title': 'BadConsole', 'console': 'xbox', 'url': 'https://h.org/x', 'license': 'MIT'},
        {'title': 'BadHash', 'console': 'gba', 'url': 'https://h.org/x.gba', 'license': 'MIT', 'sha256': 'zz'},
      ],
    };

    test('secure, known-console entries are accepted; a missing licence is recorded, not rejected', () {
      final r = parseCatalog(jsonEncode(good));
      expect(r.name, 'Test Homebrew');
      expect(r.entries.map((e) => e.title), ['Ok', 'NoLicence']);
      expect(r.entries.first.license, 'CC0-1.0');
      expect(r.entries.first.licenseStated, isTrue);
      expect(r.entries.last.license, isNull);
      expect(r.entries.last.licenseStated, isFalse);
      expect(r.entries.last.toJson()['license'], isNull);
      expect(r.rejected, hasLength(3));
      expect(r.rejected.join(), isNot(contains('licence')));
    });

    test('wrong format is rejected', () {
      expect(parseCatalog('<html>').error, isNotNull);
      expect(parseCatalog('{"format":"other"}').error, isNotNull);
      expect(parseCatalog('{"format":"gamebox-catalog","version":9,"games":[]}').error, contains('version'));
    });
  });

  group('archive guard', () {
    late Directory temp;
    setUp(() async => temp = await Directory.systemTemp.createTemp('gamebox_zip'));
    tearDown(() async => temp.delete(recursive: true));

    String write(String name, Uint8List bytes) => (File('${temp.path}/$name')..writeAsBytesSync(bytes)).path;

    test('safe entry paths', () {
      expect(safeEntryPath('NES/game.nes'), 'NES/game.nes');
      expect(safeEntryPath('./a/./b.gb'), 'a/b.gb');
      expect(safeEntryPath('../evil'), isNull);
      expect(safeEntryPath('a/../../evil'), isNull);
      expect(safeEntryPath('/etc/passwd'), isNull);
      expect(safeEntryPath(r'C:\windows\x'), isNull);
      expect(safeEntryPath(r'..\evil'), isNull);
    });

    test('valid archive extracts inside the destination', () async {
      final path = write('ok.zip', zipOf({'NES/a.nes': payload(100), 'readme.txt': utf8.encode('hi')}));
      final r = await extractZip(path, '${temp.path}/out');
      expect(r.ok, isTrue, reason: r.error);
      expect(r.files.map((f) => f.split('/out/').last), containsAll(['NES/a.nes', 'readme.txt']));
      expect(File('${temp.path}/out/NES/a.nes').readAsBytesSync(), payload(100));
    });

    test('path traversal is refused before writing anything', () async {
      final path = write('evil.zip', zipOf({'../escape.txt': utf8.encode('x'), 'ok.nes': payload(4)}));
      final i = inspectZip(path);
      expect(i.ok, isFalse);
      expect(i.problems.single, contains('Unsafe path'));
      final r = await extractZip(path, '${temp.path}/out');
      expect(r.ok, isFalse);
      expect(File('${temp.path}/escape.txt').existsSync(), isFalse);
      expect(Directory('${temp.path}/out').existsSync(), isFalse, reason: 'nothing written');
    });

    test('symlinks, entry count and compression bombs are refused', () async {
      final link = write('link.zip', zipOf({'a.nes': payload(4)}, symlinks: {'l': '/etc/passwd'}));
      expect(inspectZip(link).problems.join(), contains('Symbolic link'));

      final many = write('many.zip', zipOf({for (var i = 0; i < 20; i++) 'f$i.nes': payload(4)}));
      expect(inspectZip(many, limits: const ArchiveLimits(maxEntries: 10)).ok, isFalse);

      // 4 MB of zeros compresses ~1000:1.
      final bomb = write('bomb.zip', zipOf({'zeros.bin': Uint8List(4 * 1024 * 1024)}));
      expect(inspectZip(bomb).problems.join(), contains('ratio'));
      expect(inspectZip(bomb, limits: const ArchiveLimits(maxTotalBytes: 1024, maxRatio: 100000)).ok, isFalse);
    });

    test('not a zip', () {
      expect(inspectZip(write('x.zip', payload(50))).ok, isFalse);
    });
  });

  group('download engine (local server)', () {
    late TestServer srv;
    late Directory temp;
    late DownloadEngine engine;
    const allowed = {'nes', 'gba', 'gb', 'zip'};

    setUp(() async {
      srv = TestServer();
      await srv.start();
      temp = await Directory.systemTemp.createTemp('gamebox_dl');
      engine = DownloadEngine(allowHttp: true);
    });
    tearDown(() async {
      await srv.server.close(force: true);
      await temp.delete(recursive: true);
    });

    DownloadRequest req(String path, {String? sha, int? size, int max = 1 << 30, String? dest}) => DownloadRequest(
        url: srv.url(path), destDir: temp.path, allowedExtensions: allowed,
        expectedSha256: sha, expectedSize: size, maxBytes: max, destinationPath: dest);

    test('completes, follows a redirect, verifies SHA-256', () async {
      final data = payload(50000);
      srv.files['/game.nes'] = data;
      final o = await engine.download(req('/redirect', sha: sha256.convert(data).toString()));
      expect(o.ok, isTrue, reason: o.error);
      expect(o.path, endsWith('/game.nes'));
      expect(File(o.path!).readAsBytesSync(), data);
      expect(File('${o.path}.part').existsSync(), isFalse);
    });

    test('hash mismatch deletes the file', () async {
      srv.files['/game.nes'] = payload(1000);
      final o = await engine.download(req('/game.nes', sha: 'a' * 64));
      expect(o.kind, OutcomeKind.failed);
      expect(o.error, contains('SHA-256'));
      expect(temp.listSync(), isEmpty);
    });

    test('redirect loops and unsafe redirect targets are refused', () async {
      expect((await engine.download(req('/loop'))).error, contains('Too many redirects'));
      expect((await engine.download(req('/to-ftp'))).error, contains('https'));
    });

    test('web pages and executables are refused', () async {
      expect((await engine.download(req('/page'))).error, contains('web page'));
      srv.files['/app.apk'] = payload(10);
      expect((await engine.download(req('/app.apk'))).error, contains('never downloads apps'));
      srv.files['/notes.txt'] = payload(10);
      expect((await engine.download(req('/notes.txt'))).error, contains('not a supported'));
    });

    test('size limits and free-space check happen before downloading', () async {
      srv.files['/big.gba'] = payload(5000);
      expect((await engine.download(req('/big.gba', max: 1000))).error, contains('larger'));
      final tight = DownloadEngine(allowHttp: true, freeSpace: (_) async => 1024);
      expect((await tight.download(req('/big.gba'))).error, contains('free storage'));
      expect((await engine.download(req('/big.gba', size: 10))).error, contains('expected'));
    });

    test('Content-Disposition name is sanitised (no directory escape)', () async {
      final o = await engine.download(req('/disposition'));
      expect(o.ok, isTrue, reason: o.error);
      expect(o.path, '${temp.path}/evil name.gb');
    });

    test('truncated transfer keeps the partial file for resume', () async {
      final o = await engine.download(req('/short.gba'));
      expect(o.kind, OutcomeKind.networkError);
      expect(File('${o.path}.part').lengthSync(), 400);
    });

    test('pause then resume with HTTP Range produces an identical file', () async {
      final data = payload(64 * 1024);
      srv.files['/slow.nes'] = data;
      srv.slowGate = Completer();
      final token = CancelToken();
      String? dest;
      final first = engine.download(req('/slow.nes'), token: token, onDestination: (d) => dest = d);
      // Wait until the first chunk is on disk, then pause.
      for (var i = 0; i < 100 && (dest == null || !File('$dest.part').existsSync() || File('$dest.part').lengthSync() == 0); i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
      token.stop(StopReason.pause);
      srv.slowGate!.complete();
      final paused = await first;
      expect(paused.kind, OutcomeKind.paused);
      final partial = File('$dest.part').lengthSync();
      expect(partial, greaterThan(0));
      expect(partial, lessThan(data.length));

      srv.slowGate = null;
      final resumed = await engine.download(req('/slow.nes', dest: dest, sha: sha256.convert(data).toString()));
      expect(resumed.ok, isTrue, reason: resumed.error);
      expect(srv.rangeRequests.last, 'bytes=$partial-');
      expect(File(dest!).readAsBytesSync(), data);
    });

    test('server without Range support restarts cleanly', () async {
      final data = payload(3000);
      srv.files['/norange.gba'] = data;
      final dest = '${temp.path}/norange.gba';
      File('$dest.part').writeAsBytesSync(payload(1000).reversed.toList()); // stale partial
      final o = await engine.download(req('/norange.gba', dest: dest, sha: sha256.convert(data).toString()));
      expect(o.ok, isTrue, reason: o.error);
      expect(File(dest).readAsBytesSync(), data);
    });

    test('cancel removes the partial file', () async {
      srv.files['/slow.gba'] = payload(64 * 1024);
      srv.slowGate = Completer();
      final token = CancelToken();
      String? dest;
      final f = engine.download(req('/slow.gba'), token: token, onDestination: (d) => dest = d);
      for (var i = 0; i < 100 && dest == null; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));
      token.stop(StopReason.cancel);
      srv.slowGate!.complete();
      final o = await f;
      expect(o.kind, OutcomeKind.cancelled);
      expect(File('$dest.part').existsSync(), isFalse);
    });

    test('probe and catalogue fetch', () async {
      srv.files['/c.json'] = Uint8List.fromList(utf8.encode('{"format":"gamebox-catalog"}'));
      final p = await engine.probe(srv.url('/c.json'));
      expect(p.ok, isTrue);
      expect(p.size, 28);
      expect(await engine.fetchText(srv.url('/c.json')), contains('gamebox-catalog'));
      expect((await engine.probe(srv.url('/missing'))).ok, isFalse);
      expect((await DownloadEngine().probe(srv.url('/c.json'))).error, contains('https'),
          reason: 'production engine refuses http');
    });
  });
}
