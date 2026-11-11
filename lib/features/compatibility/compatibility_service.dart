import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';

import '../../core/constants/console_catalog.dart';
import '../../core/database/app_database.dart';
import '../../core/device/device_intelligence_service.dart';
import '../../domain/entities/performance_tier.dart';

class EffectiveRating {
  const EffectiveRating(this.rating, this.evidence, this.detail);
  final CompatibilityRating rating;
  final EvidenceLevel evidence;
  final String detail;
}

class ImportReport {
  const ImportReport({this.imported = 0, this.rejected = const [], this.error});
  final int imported;
  final List<String> rejected;
  final String? error;
}

/// Compatibility Database (spec Part 7).
///
/// Evidence precedence for a console (+ emulator) on this device:
/// verified GAMEBOX result → your own test → community report → hardware
/// estimate. Imported bundles are ALWAYS stored as community data: there is
/// no signing infrastructure that could prove a bundle is "verified", and
/// an untested community result must never be shown as verified.
class CompatibilityService {
  CompatibilityService(this._db, this._device);
  final AppDatabase _db;
  final DeviceIntelligenceService _device;

  Future<int?> _deviceId() async {
    final p = _device.state.value.profile;
    if (p == null) return null;
    final row = await (_db.select(_db.devices)..where((d) => d.deviceKey.equals(AppDatabase.deviceKeyFor(p))))
        .getSingleOrNull();
    return row?.id;
  }

  /// Records the user's own result for a game/console/emulator.
  Future<bool> recordResult({
    required String consoleId,
    required CompatibilityRating rating,
    String? emulatorId,
    int? gameId,
    String? notes,
    bool consentToShare = false,
  }) async {
    final deviceId = await _deviceId();
    if (deviceId == null) return false;
    await _db.into(_db.compatibilityTestResults).insert(CompatibilityTestResultsCompanion.insert(
          deviceId: deviceId,
          emulatorId: Value(emulatorId),
          consoleId: consoleId,
          gameId: Value(gameId),
          result: rating.name,
          source: 'local',
          notes: Value(notes?.trim().isEmpty ?? true ? null : notes!.trim()),
          consentToShare: Value(consentToShare),
          testedAt: DateTime.now(),
        ));
    return true;
  }

  static CompatibilityRating? _parse(String? s) =>
      CompatibilityRating.values.where((r) => r.name == s).firstOrNull;

  Future<EffectiveRating> effective(String consoleId, {String? emulatorId}) async {
    final p = _device.state.value.profile;
    final c = _device.state.value.classification;
    final console = consoleById(consoleId);

    if (p?.manufacturer != null && p?.model != null) {
      final q = _db.select(_db.deviceCompatibility)
        ..where((r) =>
            r.manufacturer.equals(p!.manufacturer!) & r.model.equals(p.model!) & r.consoleId.equals(consoleId))
        ..orderBy([(r) => OrderingTerm.desc(r.compatibilityDate)]);
      final rows = (await q.get())
          .where((r) => emulatorId == null || r.emulatorId == null || r.emulatorId == emulatorId)
          .toList();
      final verified = rows.where((r) => r.source == 'verified' && _parse(r.testResult) != null).firstOrNull;
      if (verified != null) {
        return EffectiveRating(_parse(verified.testResult)!, EvidenceLevel.verified,
            verified.performanceNotes ?? 'GAMEBOX test result for this model');
      }
      final deviceId = await _deviceId();
      if (deviceId != null) {
        final local = await (_db.select(_db.compatibilityTestResults)
              ..where((r) {
                final base = r.deviceId.equals(deviceId) & r.consoleId.equals(consoleId);
                return emulatorId == null ? base : base & r.emulatorId.equals(emulatorId);
              })
              ..orderBy([(r) => OrderingTerm.desc(r.testedAt)])
              ..limit(1))
            .getSingleOrNull();
        if (local != null && _parse(local.result) != null) {
          return EffectiveRating(_parse(local.result)!, EvidenceLevel.userTest, local.notes ?? 'Your result');
        }
      }
      final community = rows.where((r) => r.source == 'community' && _parse(r.testResult) != null).toList();
      if (community.isNotEmpty) {
        return EffectiveRating(_parse(community.first.testResult)!, EvidenceLevel.communityReport,
            '${community.length} community report(s) for ${p!.model} — unverified');
      }
    }
    if (p != null && c != null && console != null) {
      final emu = emulatorId == null ? null : knownEmulators.where((e) => e.id == emulatorId).firstOrNull;
      final e = _device.classifier.estimate(p, c, console, emulator: emu);
      return EffectiveRating(e.rating, e.evidence, e.reasons.join(' '));
    }
    return const EffectiveRating(CompatibilityRating.notTested, EvidenceLevel.hardwareEstimate, 'No data');
  }

  /// Imports a `gamebox-compat` bundle. Every row is stored as community data.
  Future<ImportReport> importBundle(String body, {required String batchId}) async {
    Object? json;
    try {
      json = jsonDecode(body);
    } catch (_) {
      return const ImportReport(error: 'Not valid JSON');
    }
    if (json is! Map || json['format'] != 'gamebox-compat' || json['version'] != 1 || json['results'] is! List) {
      return const ImportReport(error: 'Not a GAMEBOX compatibility bundle (format "gamebox-compat", version 1)');
    }
    var n = 0;
    final rejected = <String>[];
    for (final (i, raw) in (json['results'] as List).indexed) {
      String? s(String k) => raw is Map && raw[k] is String && (raw[k] as String).trim().isNotEmpty ? (raw[k] as String).trim() : null;
      final manufacturer = s('manufacturer'), model = s('model'), console = s('console'), result = s('result');
      final emulator = s('emulator');
      if (raw is! Map || manufacturer == null || model == null) {
        rejected.add('#${i + 1}: manufacturer and model are required');
        continue;
      }
      if (console == null || consoleById(console) == null) {
        rejected.add('#${i + 1}: unknown console');
        continue;
      }
      if (_parse(result) == null) {
        rejected.add('#${i + 1}: invalid result');
        continue;
      }
      if (emulator != null && knownEmulators.every((e) => e.id != emulator)) {
        rejected.add('#${i + 1}: unknown emulator');
        continue;
      }
      await _db.into(_db.deviceCompatibility).insert(DeviceCompatibilityCompanion.insert(
            source: 'community',
            manufacturer: manufacturer,
            model: model,
            chipset: Value(s('chipset')),
            gpu: Value(s('gpu')),
            androidVersion: Value(s('android')),
            emulatorId: Value(emulator),
            consoleId: Value(console),
            testedGame: Value(s('game')),
            testResult: Value(result),
            performanceNotes: Value(s('notes')),
            compatibilityDate: DateTime.tryParse(s('date') ?? '') ?? DateTime.now(),
            importBatch: Value(batchId),
          ));
      n++;
    }
    return ImportReport(imported: n, rejected: rejected);
  }

  /// Writes an anonymous report with ONLY results the user agreed to share,
  /// plus coarse hardware facts (no serials, build fingerprint or IDs).
  /// GAMEBOX has no submission server; the user shares the file manually.
  Future<String?> exportAnonymousReport(String dir) async {
    final p = _device.state.value.profile;
    final deviceId = await _deviceId();
    if (p == null || deviceId == null) return null;
    final results = await (_db.select(_db.compatibilityTestResults)
          ..where((r) => r.deviceId.equals(deviceId) & r.consentToShare.equals(true)))
        .get();
    final gb = p.totalRamBytes == null ? null : (p.totalRamBytes! / (1024 * 1024 * 1024)).round();
    final bundle = {
      'format': 'gamebox-compat',
      'version': 1,
      'results': [
        for (final r in results)
          {
            'manufacturer': p.manufacturer,
            'model': p.model,
            'chipset': p.socModel,
            'gpu': p.glRenderer,
            'ramGb': gb,
            'android': p.androidVersion,
            'console': r.consoleId,
            'emulator': r.emulatorId,
            'result': r.result,
            'notes': r.notes,
            'date': r.testedAt.toIso8601String().substring(0, 10),
          },
      ],
    };
    final f = File('$dir/gamebox_compat_report_${DateTime.now().millisecondsSinceEpoch}.json');
    await f.parent.create(recursive: true);
    await f.writeAsString(const JsonEncoder.withIndent('  ').convert(bundle));
    await (_db.update(_db.compatibilityTestResults)
          ..where((r) => r.deviceId.equals(deviceId) & r.consentToShare.equals(true)))
        .write(const CompatibilityTestResultsCompanion(submitted: Value(true)));
    return f.path;
  }
}
