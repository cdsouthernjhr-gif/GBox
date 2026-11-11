import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' show Value, OrderingTerm;

import '../../core/database/app_database.dart';
import '../../core/device/device_intelligence_service.dart';

enum BenchmarkType { cpuSingle, cpuMulti, memory, storageWrite, storageRead, uiFrames }

extension BenchmarkTypeLabel on BenchmarkType {
  String get label => switch (this) {
        BenchmarkType.cpuSingle => 'CPU (1 core)',
        BenchmarkType.cpuMulti => 'CPU (all cores)',
        BenchmarkType.memory => 'Memory copy',
        BenchmarkType.storageWrite => 'Storage write',
        BenchmarkType.storageRead => 'Storage read',
        BenchmarkType.uiFrames => 'Launcher rendering',
      };

  String get unit => switch (this) {
        BenchmarkType.cpuSingle || BenchmarkType.cpuMulti => 'MB/s SHA-256',
        BenchmarkType.memory => 'MB/s',
        BenchmarkType.storageWrite || BenchmarkType.storageRead => 'MB/s',
        BenchmarkType.uiFrames => 'FPS',
      };
}

class BenchmarkResult {
  const BenchmarkResult(this.type, this.score, this.durationMs, {this.averageFps, this.minimumFps, this.notes});
  final BenchmarkType type;
  final double score;
  final int durationMs;
  final double? averageFps;
  final double? minimumFps;
  final String? notes;
}

/// SHA-256 over [mb] MB, returns MB/s. Top-level so it can run in an isolate.
double _hashWork(int mb) {
  final data = Uint8List(1024 * 1024);
  for (var i = 0; i < data.length; i++) {
    data[i] = i & 0xFF;
  }
  final sw = Stopwatch()..start();
  for (var i = 0; i < mb; i++) {
    sha256.convert(data);
  }
  return mb / (sw.elapsedMicroseconds / 1e6);
}

double _memoryWork(int mb) {
  final a = Uint8List(mb * 1024 * 1024);
  final b = Uint8List(mb * 1024 * 1024);
  final sw = Stopwatch()..start();
  const passes = 8;
  for (var i = 0; i < passes; i++) {
    b.setRange(0, b.length, a);
    a[i] = b[i] + 1;
  }
  return mb * passes / (sw.elapsedMicroseconds / 1e6);
}

/// Device micro-benchmarks (Phase 7). These measure the box itself — they do
/// NOT measure emulator FPS, which external emulator apps do not expose.
/// Results are stored per device in the `benchmarks` table.
class BenchmarkService {
  BenchmarkService(this._db, this._device);
  final AppDatabase _db;
  final DeviceIntelligenceService _device;

  Future<BenchmarkResult> cpuSingle({int mb = 64}) async {
    final sw = Stopwatch()..start();
    final score = await Isolate.run(() => _hashWork(mb));
    return BenchmarkResult(BenchmarkType.cpuSingle, score, sw.elapsedMilliseconds);
  }

  Future<BenchmarkResult> cpuMulti({int mbPerCore = 32, int? cores}) async {
    final n = (cores ?? _device.state.value.profile?.cpuCores ?? Platform.numberOfProcessors).clamp(1, 8);
    final sw = Stopwatch()..start();
    final scores = await Future.wait([for (var i = 0; i < n; i++) Isolate.run(() => _hashWork(mbPerCore))]);
    return BenchmarkResult(BenchmarkType.cpuMulti, scores.fold<double>(0, (a, b) => a + b), sw.elapsedMilliseconds,
        notes: '$n isolates');
  }

  /// 2 × [mb] MB of RAM; kept small for 2 GB devices.
  Future<BenchmarkResult> memory({int mb = 16}) async {
    final sw = Stopwatch()..start();
    final score = await Isolate.run(() => _memoryWork(mb));
    return BenchmarkResult(BenchmarkType.memory, score, sw.elapsedMilliseconds);
  }

  /// Sequential write then read of a temporary file in [dir]. The file is
  /// deleted afterwards. Read speed may include OS caching.
  Future<List<BenchmarkResult>> storage(String dir, {int mb = 32}) async {
    final f = File('$dir/.gamebox_bench_${DateTime.now().microsecondsSinceEpoch}');
    final chunk = Uint8List(1024 * 1024);
    for (var i = 0; i < chunk.length; i++) {
      chunk[i] = (i * 13) & 0xFF;
    }
    try {
      await f.parent.create(recursive: true);
      final sw = Stopwatch()..start();
      final raf = await f.open(mode: FileMode.write);
      for (var i = 0; i < mb; i++) {
        await raf.writeFrom(chunk);
      }
      await raf.flush();
      await raf.close();
      final writeMs = sw.elapsedMilliseconds;
      sw
        ..reset()
        ..start();
      var read = 0;
      await for (final c in f.openRead()) {
        read += c.length;
      }
      final readMs = sw.elapsedMilliseconds;
      double rate(int bytes, int ms) => bytes / (1024 * 1024) / (ms.clamp(1, 1 << 31) / 1000);
      return [
        BenchmarkResult(BenchmarkType.storageWrite, rate(mb * 1024 * 1024, writeMs), writeMs, notes: dir),
        BenchmarkResult(BenchmarkType.storageRead, rate(read, readMs), readMs, notes: '$dir (may be cached)'),
      ];
    } finally {
      if (await f.exists()) await f.delete();
    }
  }

  /// Stores results for the current device. Returns false without a profile.
  Future<bool> save(List<BenchmarkResult> results) async {
    final p = _device.state.value.profile;
    if (p == null) return false;
    final device = await (_db.select(_db.devices)..where((d) => d.deviceKey.equals(AppDatabase.deviceKeyFor(p))))
        .getSingleOrNull();
    if (device == null) return false;
    for (final r in results) {
      await _db.into(_db.benchmarks).insert(BenchmarksCompanion.insert(
            deviceId: device.id,
            benchmarkType: r.type.name,
            score: Value(r.score),
            averageFps: Value(r.averageFps),
            minimumFps: Value(r.minimumFps),
            durationMs: r.durationMs,
            notes: Value(r.notes),
            ranAt: DateTime.now(),
          ));
    }
    return true;
  }

  Future<List<BenchmarkRow>> history({int limit = 30}) => (_db.select(_db.benchmarks)
        ..orderBy([(b) => OrderingTerm.desc(b.ranAt)])
        ..limit(limit))
      .get();
}
