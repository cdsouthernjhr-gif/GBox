import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// Lightweight local log (no network). Keeps the last ~256 KB on disk in
/// `<app support>/logs/gamebox.log` plus an in-memory tail for the UI.
class AppLogger {
  AppLogger._();
  static final AppLogger instance = AppLogger._();

  static const _maxBytes = 256 * 1024;
  static const _memoryLines = 300;

  final List<String> _tail = [];
  File? _file;
  Future<void> _pending = Future.value();

  List<String> get recent => List.unmodifiable(_tail);
  String? get logPath => _file?.path;

  Future<void> attachFile(Directory dir) async {
    try {
      final logs = Directory('${dir.path}/logs');
      await logs.create(recursive: true);
      final f = File('${logs.path}/gamebox.log');
      if (await f.exists() && await f.length() > _maxBytes) {
        final old = File('${logs.path}/gamebox.1.log');
        if (await old.exists()) await old.delete();
        await f.rename(old.path);
      }
      _file = File('${logs.path}/gamebox.log');
    } catch (e) {
      debugPrint('Log file unavailable: $e');
    }
  }

  void info(String message) => _write('INFO', message);
  void warn(String message) => _write('WARN', message);

  void error(String message, [Object? error, StackTrace? stack]) {
    final buf = StringBuffer(message);
    if (error != null) buf.write(': $error');
    if (stack != null) {
      buf.write('\n${stack.toString().split('\n').take(12).join('\n')}');
    }
    _write('ERROR', buf.toString());
  }

  void _write(String level, String message) {
    final line = '${DateTime.now().toIso8601String()} [$level] $message';
    if (kDebugMode) debugPrint(line);
    _tail.add(line);
    if (_tail.length > _memoryLines) _tail.removeRange(0, _tail.length - _memoryLines);
    final f = _file;
    if (f != null) {
      _pending = _pending.then((_) async {
        try {
          await f.writeAsString('$line\n', mode: FileMode.append, flush: false);
        } catch (_) {}
      });
    }
  }
}
