import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamebox/core/constants/console_catalog.dart';
import 'package:gamebox/core/database/app_database.dart';
import 'package:gamebox/core/device/device_intelligence_service.dart';
import 'package:gamebox/core/device/performance_classifier.dart';
import 'package:gamebox/domain/entities/hardware_profile.dart';

import 'support/fakes.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
  });
  tearDown(() => db.close());

  Future<int> addGame(String title, {String console = 'nes'}) => db.into(db.games).insert(
        GamesCompanion.insert(
          title: title,
          sortTitle: title.toLowerCase(),
          consoleId: console,
          addedAt: DateTime.now(),
        ),
      );

  test('schema creates all 26 tables', () async {
    final rows = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type='table' "
            "AND name NOT LIKE 'sqlite_%'")
        .get();
    final names = rows.map((r) => r.read<String>('name')).toSet();
    const expected = {
      'devices', 'device_hardware_profiles', 'device_compatibility',
      'compatibility_test_results', 'consoles', 'emulators', 'emulator_profiles',
      'emulator_adapters', 'games', 'game_files', 'game_metadata', 'game_artworks',
      'favorites', 'game_history', 'controller_devices', 'controller_profiles',
      'controller_mappings', 'storage_devices', 'game_sources', 'source_connectors',
      'download_queue', 'download_history', 'save_states', 'save_backups',
      'benchmarks', 'app_settings',
    };
    expect(names, containsAll(expected));
    expect(expected.length, 26);
  });

  test('catalogue is seeded and re-seeding is idempotent', () async {
    await db.seedCatalog();
    await db.seedCatalog();
    expect(await db.select(db.consoles).get(), hasLength(consoleCatalog.length));
    expect(await db.select(db.emulators).get(), hasLength(knownEmulators.length));
  });

  test('foreign keys are enforced', () async {
    expect(() => addGame('Bad', console: 'not-a-console'), throwsA(isA<SqliteException>()));
  });

  test('check constraints reject invalid compatibility source', () async {
    expect(
      () => db.into(db.deviceCompatibility).insert(DeviceCompatibilityCompanion.insert(
            source: 'made_up',
            manufacturer: 'x',
            model: 'y',
            compatibilityDate: DateTime.now(),
          )),
      throwsA(isA<SqliteException>()),
    );
  });

  test('hardware profile is stored and restored offline', () async {
    final p = DeviceIntelligenceService.profileFromNative(syntheticNativeScan(), now: DateTime(2026, 3, 4));
    const classifier = PerformanceClassifier();
    final id1 = await db.saveHardwareProfile(p, classifier.classify(p));
    final id2 = await db.saveHardwareProfile(p, classifier.classify(p));
    expect(id1, id2, reason: 'same device is not duplicated');
    expect(await db.select(db.devices).get(), hasLength(1));
    expect(await db.select(db.deviceHardwareProfiles).get(), hasLength(2));

    final restored = await db.latestHardwareProfile();
    expect(restored!.toMap(), p.toMap());

    final detected = await db.compatibilityHistory();
    expect(detected.every((r) => r.source == 'detected'), isTrue);
  });

  test('settings persist', () async {
    expect(await db.getSetting('general.theme'), isNull);
    await db.setSetting('general.theme', 'retroArcade');
    await db.setSetting('general.theme', 'minimal');
    expect(await db.getSetting('general.theme'), 'minimal');
  });

  test('favourites and library streams', () async {
    final a = await addGame('Alpha');
    await addGame('Beta', console: 'snes');
    await db.setFavorite(a, true);

    final favs = await db.watchFavorites().first;
    expect(favs.map((g) => g.game.title), ['Alpha']);
    expect((await db.watchAllGames().first).map((g) => g.game.title), ['Alpha', 'Beta']);
    expect(await db.watchGameCountsByConsole().first, {'nes': 1, 'snes': 1});

    await db.setFavorite(a, false);
    expect(await db.watchFavorites().first, isEmpty);
  });

  test('removing a game from the library cascades to its file references only', () async {
    final id = await addGame('Gamma');
    final dir = await Directory.systemTemp.createTemp('gamebox_test');
    final rom = File('${dir.path}/gamma.nes')..writeAsBytesSync([0x4e, 0x45, 0x53, 0x1a]);
    await db.into(db.gameFiles).insert(GameFilesCompanion.insert(
        gameId: id, uri: rom.path, displayPath: 'gamma.nes', extension: 'nes'));
    await db.setFavorite(id, true);

    await db.removeGameFromLibrary(id);
    expect(await db.select(db.gameFiles).get(), isEmpty);
    expect(await db.select(db.favorites).get(), isEmpty);
    expect(rom.existsSync(), isTrue, reason: 'original file is never deleted');
    await dir.delete(recursive: true);
  });

  test('emulator detection upserts without duplicates', () async {
    await db.saveEmulatorDetection({'org.ppsspp.ppsspp': '1.17'});
    await db.saveEmulatorDetection({});
    final rows = await db.select(db.emulatorAdapters).get();
    expect(rows, hasLength(allKnownEmulatorPackages.length));
    final ppsspp = rows.firstWhere((r) => r.packageName == 'org.ppsspp.ppsspp');
    expect(ppsspp.installed, isFalse, reason: 'second scan saw it uninstalled');
  });

  test('storage volumes not seen in a scan are marked disconnected', () async {
    const usb = StorageVolumeInfo(
        id: 'ABCD-1234', description: 'USB drive', isPrimary: false, isRemovable: true,
        isEmulated: false, state: 'mounted', kind: StorageKind.usb);
    const internal = StorageVolumeInfo(
        id: 'primary', description: 'Internal', isPrimary: true, isRemovable: false,
        isEmulated: true, state: 'mounted', kind: StorageKind.internal);
    await db.recordStorageVolumes([internal, usb]);
    await db.recordStorageVolumes([internal]);
    final rows = await db.watchStorageDevices().first;
    expect(rows.firstWhere((r) => r.volumeId == 'ABCD-1234').isConnected, isFalse);
    expect(rows.firstWhere((r) => r.volumeId == 'primary').isConnected, isTrue);
  });

  test('controllers are recorded once per descriptor', () async {
    final pads = [InputDeviceInfo.fromMap(
        (syntheticNativeScan()['inputDevices'] as List).first as Map<String, dynamic>)];
    await db.recordControllers(pads);
    await db.recordControllers(pads);
    final rows = await db.knownControllers();
    expect(rows, hasLength(1));
    expect(rows.single.vendorId, 0x045e);
  });

  test('ROM binaries are never stored: game_files has no blob column', () async {
    final cols = await db.customSelect('PRAGMA table_info(game_files)').get();
    expect(cols.map((c) => c.read<String>('type').toUpperCase()), isNot(contains('BLOB')));
  });
}
