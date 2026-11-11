import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamebox/core/database/app_database.dart';
import 'package:gamebox/core/database/db_maintenance.dart';
import 'package:gamebox/core/device/device_intelligence_service.dart';
import 'package:gamebox/core/saves/save_classifier.dart';
import 'package:gamebox/data/repositories/settings_repository.dart';
import 'package:gamebox/domain/entities/performance_tier.dart';
import 'package:gamebox/features/compatibility/compatibility_service.dart';
import 'package:gamebox/features/performance/benchmark_service.dart';
import 'package:gamebox/features/save_manager/save_service.dart';

import 'support/fakes.dart';

void main() {
  group('save classifier', () {
    test('kinds and slots', () {
      expect(classifySave('Game (USA).srm')!.kind, SaveKind.native);
      expect(classifySave('card1.mcd')!.kind, SaveKind.memcard);
      expect(classifySave('Game.state')!.slot, 0);
      expect(classifySave('Game.state3')!.slot, 3);
      expect(classifySave('Game.state.auto')!.slot, -1);
      expect(classifySave('ULUS10041_1.00_2.ppst')!.slot, 2);
      expect(classifySave('Game.nes'), isNull);
    });

    test('matching to games is unique or nothing', () {
      final c = {
        1: ['Pixel Quest', 'Pixel Quest (USA).nes'],
        2: ['Farm Life', 'farm_life.gba'],
        3: ['Twin', 'twin.gb'],
        4: ['Twin', 'twin.gbc'],
      };
      expect(matchSaveToGame('Pixel Quest (USA).state2', c), 1);
      expect(matchSaveToGame('farm_life.srm', c), 2);
      expect(matchSaveToGame('Twin.sav', c), isNull, reason: 'ambiguous');
      expect(matchSaveToGame('Unknown.srm', c), isNull);
      expect(saveBaseName('Game.state.auto'), 'Game');
    });
  });

  group('services', () {
    late Directory temp;
    late AppDatabase db;
    late FakeGateway gateway;
    late SettingsRepository settings;
    late DeviceIntelligenceService device;
    late SaveService saves;
    late int gameId;
    late String saveDir;

    setUp(() async {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      temp = await Directory.systemTemp.createTemp('gamebox_p7');
      db = AppDatabase(NativeDatabase.memory());
      gateway = FakeGateway();
      settings = SettingsRepository(db);
      await settings.initialize();
      device = DeviceIntelligenceService(gateway, db);
      await device.scan();
      saves = SaveService(gateway: gateway, db: db, settings: settings, gameboxRoot: () async => '${temp.path}/GAMEBOX');
      gameId = await db.insertGameWithFiles(
        GamesCompanion.insert(title: 'Pixel Quest', sortTitle: 'pixel quest', consoleId: 'nes', addedAt: DateTime(2026)),
        [GameFilesCompanion.insert(gameId: 0, uri: '/roms/Pixel Quest (USA).nes', displayPath: 'Pixel Quest (USA).nes', extension: 'nes')],
      );
      saveDir = '${temp.path}/RetroArch/saves';
      Directory(saveDir).createSync(recursive: true);
      File('$saveDir/Pixel Quest (USA).srm').writeAsBytesSync([1, 2, 3, 4]);
      File('$saveDir/Pixel Quest (USA).state1').writeAsBytesSync([9, 9]);
      File('$saveDir/Unrelated.srm').writeAsBytesSync([0]);
      await saves.addFolder(saveDir, 'retroarch');
      await Future<void>.delayed(const Duration(milliseconds: 30));
    });

    tearDown(() async {
      settings.dispose();
      await db.close();
      await temp.delete(recursive: true);
    });

    test('scan finds, classifies and links saves; unmatched are reported', () async {
      final r = await saves.scan();
      expect(r.found, 3);
      expect(r.matched, 2);
      expect(r.unmatched, ['Unrelated.srm']);
      final rows = await db.watchSavesForGame(gameId).first;
      expect(rows.map((s) => s.kind).toSet(), {'native', 'state'});
      expect(rows.firstWhere((s) => s.kind == 'state').slot, 1);
    });

    test('backup, then restore with an automatic safety copy', () async {
      await saves.scan();
      expect(await saves.backupGame(gameId, note: 'before boss'), 2);
      final srm = File('$saveDir/Pixel Quest (USA).srm');
      srm.writeAsBytesSync([7, 7, 7]); // game progress overwritten
      final backups = await db.watchBackupsForGame(gameId).first;
      final srmBackup = backups.firstWhere((b) => b.backupPath.endsWith('.srm'));

      final r = await saves.restore(srmBackup.id);
      expect(r.ok, isTrue, reason: r.message);
      expect(srm.readAsBytesSync(), [1, 2, 3, 4]);
      final after = await db.watchBackupsForGame(gameId).first;
      final safety = after.firstWhere((b) => b.note == 'Automatic copy before restore');
      expect(File(safety.backupPath).readAsBytesSync(), [7, 7, 7], reason: 'restore can be undone');
    });

    test('restore refuses when the original save is unknown or the backup is gone', () async {
      await saves.scan();
      await saves.backupGame(gameId);
      final b = (await db.watchBackupsForGame(gameId).first).first;
      File(b.backupPath).deleteSync();
      expect((await saves.restore(b.id)).ok, isFalse);
      expect((await saves.restore(9999)).ok, isFalse);
    });

    test('unreadable save folder is reported, not cleared', () async {
      await saves.scan();
      Directory(saveDir).deleteSync(recursive: true);
      final r = await saves.scan();
      expect(r.unavailable, [saveDir]);
      expect(await db.watchSavesForGame(gameId).first, hasLength(2), reason: 'kept until the folder is back');
    });

    test('export ZIP and import back (safe paths only)', () async {
      await saves.scan();
      final zip = await saves.exportGame(gameId);
      final archive = ZipDecoder().decodeBytes(File(zip!).readAsBytesSync());
      expect(archive.files.map((f) => f.name).toSet(), {'Pixel Quest (USA).srm', 'Pixel Quest (USA).state1'});

      File('$saveDir/Pixel Quest (USA).srm').writeAsBytesSync([5]);
      final r = await saves.importZip(zip);
      expect(r.ok, isTrue, reason: r.message);
      expect(File('$saveDir/Pixel Quest (USA).srm').readAsBytesSync(), [1, 2, 3, 4]);

      final evil = Archive()..add(ArchiveFile.bytes('../../escape.srm', [1]));
      final evilPath = '${temp.path}/evil.zip';
      File(evilPath).writeAsBytesSync(ZipEncoder().encode(evil));
      expect((await saves.importZip(evilPath)).ok, isFalse);
      expect(File('${temp.path}/escape.srm').existsSync(), isFalse);
    });

    test('compatibility evidence precedence and import policy', () async {
      final compat = CompatibilityService(db, device);
      expect((await compat.effective('nes')).evidence, EvidenceLevel.hardwareEstimate);

      final bundle = jsonEncode({
        'format': 'gamebox-compat',
        'version': 1,
        'results': [
          {'manufacturer': 'TestVendor', 'model': 'Synthetic Box', 'console': 'nes', 'result': 'limited'},
          {'manufacturer': 'X', 'model': 'Y', 'console': 'xbox', 'result': 'good'},
          {'manufacturer': 'X', 'model': 'Y', 'console': 'nes', 'result': 'perfect'},
        ],
      });
      final rep = await compat.importBundle(bundle, batchId: 'b1');
      expect(rep.imported, 1);
      expect(rep.rejected, hasLength(2));
      final community = await compat.effective('nes');
      expect(community.evidence, EvidenceLevel.communityReport);
      expect(community.rating, CompatibilityRating.limited);
      final rows = await db.select(db.deviceCompatibility).get();
      expect(rows.where((r) => r.source == 'verified'), isEmpty, reason: 'imports are never verified');

      await compat.recordResult(consoleId: 'nes', rating: CompatibilityRating.excellent, emulatorId: 'retroarch');
      expect((await compat.effective('nes')).evidence, EvidenceLevel.userTest);
      expect((await compat.effective('nes', emulatorId: 'retroarch')).rating, CompatibilityRating.excellent);

      await db.into(db.deviceCompatibility).insert(DeviceCompatibilityCompanion.insert(
            source: 'verified', manufacturer: 'TestVendor', model: 'Synthetic Box',
            consoleId: const Value('nes'), testResult: const Value('good'), compatibilityDate: DateTime(2026)));
      expect((await compat.effective('nes')).evidence, EvidenceLevel.verified);
    });

    test('anonymous report contains only consented results and no identifiers', () async {
      final compat = CompatibilityService(db, device);
      await compat.recordResult(consoleId: 'nes', rating: CompatibilityRating.good, consentToShare: true, notes: 'smooth');
      await compat.recordResult(consoleId: 'snes', rating: CompatibilityRating.limited);
      final path = await compat.exportAnonymousReport(temp.path);
      final text = File(path!).readAsStringSync();
      final json = jsonDecode(text) as Map;
      expect((json['results'] as List).map((r) => r['console']), ['nes']);
      expect(text, isNot(contains('release-keys')), reason: 'no build fingerprint');
      expect(text, isNot(contains('TEST.1')), reason: 'no build id');
      final again = await compat.importBundle(text, batchId: 'roundtrip');
      expect(again.imported, 1, reason: 'export uses the import format');
    });

    test('library database backup and staged restore', () async {
      final file = '${temp.path}/live.sqlite';
      final live = AppDatabase(NativeDatabase(File(file)));
      await live.setSetting('k', 'original');
      final backup = '${temp.path}/backup.sqlite';
      await live.backupTo(backup);
      await live.setSetting('k', 'changed');
      await live.close();

      expect(isSqliteFile(File(backup)), isTrue);
      File('${temp.path}/junk.bin').writeAsBytesSync(Uint8List(32));
      expect(() => stageRestore('${temp.path}/junk.bin', file), throwsFormatException);

      await stageRestore(backup, file);
      expect(await applyPendingRestore(file), contains('restored'));
      expect(File('${temp.path}/$beforeRestoreName').existsSync(), isTrue);
      expect(await applyPendingRestore(file), isNull, reason: 'applied once');

      final restored = AppDatabase(NativeDatabase(File(file)));
      expect(await restored.getSetting('k'), 'original');
      await restored.close();
    });

    test('benchmarks produce positive scores and are stored per device', () async {
      final bench = BenchmarkService(db, device);
      final results = [
        await bench.cpuSingle(mb: 2),
        await bench.cpuMulti(mbPerCore: 1, cores: 2),
        await bench.memory(mb: 2),
        ...await bench.storage(temp.path, mb: 2),
      ];
      for (final r in results) {
        expect(r.score, greaterThan(0), reason: r.type.name);
      }
      expect(temp.listSync().where((e) => e.path.contains('.gamebox_bench')), isEmpty, reason: 'temp file removed');
      expect(await bench.save(results), isTrue);
      expect((await bench.history()).map((b) => b.benchmarkType).toSet(),
          {'cpuSingle', 'cpuMulti', 'memory', 'storageWrite', 'storageRead'});
    });
  });
}
