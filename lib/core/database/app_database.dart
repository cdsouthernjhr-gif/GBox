import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../domain/entities/hardware_profile.dart';
import '../../domain/entities/performance_tier.dart';
import '../constants/console_catalog.dart';
import '../device/performance_classifier.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// Joined view of a game with its favourite flag, used by library widgets.
class GameWithStatus {
  const GameWithStatus(this.game, this.isFavorite);
  final GameRow game;
  final bool isFavorite;
}

@DriftDatabase(tables: [
  Devices,
  DeviceHardwareProfiles,
  DeviceCompatibility,
  CompatibilityTestResults,
  Consoles,
  Emulators,
  EmulatorProfiles,
  EmulatorAdapters,
  Games,
  GameFiles,
  GameMetadata,
  GameArtworks,
  Favorites,
  GameHistory,
  ControllerDevices,
  ControllerProfiles,
  ControllerMappings,
  StorageDevices,
  GameSources,
  SourceConnectors,
  DownloadQueue,
  DownloadHistory,
  SaveStates,
  SaveBackups,
  Benchmarks,
  AppSettings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Opens the on-device database file (`gamebox.sqlite` in app support dir).
  factory AppDatabase.open() =>
      AppDatabase(driftDatabase(name: 'gamebox'));

  /// Bump on every schema change and add a step in [migration].
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // Future versions: add `if (from < N) { ... }` steps here, never
          // drop user tables. See docs/DATABASE_SCHEMA.md.
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          await seedCatalog();
        },
      );

  /// Upserts the static console/emulator/connector catalogue so new app
  /// versions can extend it without a migration.
  Future<void> seedCatalog() async {
    await batch((b) {
      b.insertAllOnConflictUpdate(consoles, [
        for (final c in consoleCatalog)
          ConsolesCompanion.insert(
            id: c.id,
            name: c.name,
            manufacturer: c.manufacturer,
            category: c.category.name,
            folderName: c.folderName,
            extensions: c.extensions.join(','),
            minTier: c.minTier.name,
            recommendedTier: c.recommendedTier.name,
          ),
      ]);
      b.insertAllOnConflictUpdate(emulators, [
        for (final e in knownEmulators)
          EmulatorsCompanion.insert(
            id: e.id,
            name: e.name,
            license: e.license,
            strategy: e.strategy.name,
            requiresArm64: Value(e.requiresArm64),
            minSdk: Value(e.minSdk),
            consoleIds: e.consoleIds.join(','),
            notes: Value(e.notes),
          ),
      ]);
      b.insertAllOnConflictUpdate(sourceConnectors, [
        SourceConnectorsCompanion.insert(
          id: 'direct_url',
          name: 'Direct download URL',
          type: 'direct_url',
          version: '1',
          description: const Value('Single HTTPS file URL supplied by the user.'),
        ),
      ]);
    });
  }

  // ------------------------------------------------------------ settings --

  Future<String?> getSetting(String key) async {
    final row = await (select(appSettings)..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Stream<Map<String, String>> watchSettings() =>
      select(appSettings).watch().map((rows) => {
            for (final r in rows) r.key: r.value,
          });

  Future<void> setSetting(String key, String value) =>
      into(appSettings).insertOnConflictUpdate(AppSettingsCompanion.insert(
        key: key,
        value: value,
        updatedAt: DateTime.now(),
      ));

  // ------------------------------------------------------------- devices --

  static String deviceKeyFor(HardwareProfile p) => [
        p.manufacturer ?? 'unknown',
        p.model ?? 'unknown',
        p.device ?? 'unknown',
        p.buildFingerprint ?? 'unknown',
      ].join('|');

  /// Records the device and stores a new hardware profile snapshot.
  /// Returns the device row id.
  Future<int> saveHardwareProfile(
    HardwareProfile p,
    DeviceClassification c,
  ) {
    return transaction(() async {
      final key = deviceKeyFor(p);
      final now = DateTime.now();
      final existing = await (select(devices)
            ..where((d) => d.deviceKey.equals(key)))
          .getSingleOrNull();
      final int deviceId;
      if (existing == null) {
        deviceId = await into(devices).insert(DevicesCompanion.insert(
          deviceKey: key,
          manufacturer: Value(p.manufacturer),
          model: Value(p.model),
          deviceName: Value(p.device),
          androidVersion: Value(p.androidVersion),
          sdkInt: Value(p.sdkInt),
          buildFingerprint: Value(p.buildFingerprint),
          firstSeenAt: now,
          lastSeenAt: now,
        ));
      } else {
        deviceId = existing.id;
        await (update(devices)..where((d) => d.id.equals(deviceId))).write(
          DevicesCompanion(
            androidVersion: Value(p.androidVersion),
            sdkInt: Value(p.sdkInt),
            lastSeenAt: Value(now),
          ),
        );
      }
      await into(deviceHardwareProfiles)
          .insert(DeviceHardwareProfilesCompanion.insert(
        deviceId: deviceId,
        scannedAt: p.scannedAt,
        tier: c.tier.name,
        confidence: c.confidence,
        abis: p.supportedAbis.join(','),
        cpuDescription: Value(p.cpuModel),
        cpuCores: Value(p.cpuCores),
        totalRamBytes: Value(p.totalRamBytes),
        glRenderer: Value(p.glRenderer),
        glEsVersion: Value(p.glEsVersion),
        vulkanSupported: Value(p.vulkanSupported),
        displayWidth: Value(p.displayWidth),
        displayHeight: Value(p.displayHeight),
        rawJson: jsonEncode(p.toMap()),
      ));

      // (A) Automatically detected hardware entry in the compatibility DB.
      await into(deviceCompatibility).insert(DeviceCompatibilityCompanion.insert(
        source: 'detected',
        manufacturer: p.manufacturer ?? 'UNKNOWN',
        model: p.model ?? 'UNKNOWN',
        chipset: Value(p.socModel ?? p.hardware),
        cpuArchitecture: Value(p.supportedAbis.join(',')),
        cpuCharacteristics: Value(p.cpuModel),
        gpu: Value(p.glRenderer),
        ramBytes: Value(p.totalRamBytes),
        androidVersion: Value(p.androidVersion),
        graphicsApi: Value([
          if (p.glEsVersion != null) 'OpenGL ES ${p.glEsVersion}',
          if (p.vulkanSupported == true)
            'Vulkan ${p.vulkanApiVersion ?? ''}'.trim(),
        ].join(', ')),
        testResult: Value('tier:${c.tier.name}'),
        compatibilityDate: now,
      ));

      // Keep only the 20 most recent snapshots per device.
      await customStatement(
        'DELETE FROM device_hardware_profiles WHERE device_id = ? AND id NOT IN '
        '(SELECT id FROM device_hardware_profiles WHERE device_id = ? '
        'ORDER BY scanned_at DESC LIMIT 20)',
        [deviceId, deviceId],
      );
      return deviceId;
    });
  }

  Future<HardwareProfile?> latestHardwareProfile() async {
    final row = await (select(deviceHardwareProfiles)
          ..orderBy([(t) => OrderingTerm.desc(t.scannedAt)])
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return null;
    try {
      return HardwareProfile.fromMap(
          Map<String, dynamic>.from(jsonDecode(row.rawJson) as Map));
    } on FormatException {
      return null;
    }
  }

  Future<List<HardwareProfileRow>> hardwareProfileHistory({int limit = 20}) =>
      (select(deviceHardwareProfiles)
            ..orderBy([(t) => OrderingTerm.desc(t.scannedAt)])
            ..limit(limit))
          .get();

  // --------------------------------------------------------------- games --

  Stream<int> watchGameCount() {
    final count = games.id.count();
    return (selectOnly(games)..addColumns([count]))
        .map((r) => r.read(count) ?? 0)
        .watchSingle();
  }

  Stream<List<GameWithStatus>> _watchGames(
    void Function(SimpleSelectStatement<$GamesTable, GameRow>) configure, {
    bool favoritesOnly = false,
  }) {
    final q = select(games);
    configure(q);
    final joined = q.join([
      leftOuterJoin(favorites, favorites.gameId.equalsExp(games.id)),
    ]);
    if (favoritesOnly) joined.where(favorites.gameId.isNotNull());
    return joined.watch().map((rows) => [
          for (final r in rows)
            GameWithStatus(r.readTable(games), r.readTableOrNull(favorites) != null),
        ]);
  }

  Stream<List<GameWithStatus>> watchRecentlyPlayed({int limit = 20}) =>
      _watchGames((q) => q
        ..where((g) => g.lastPlayedAt.isNotNull())
        ..orderBy([(g) => OrderingTerm.desc(g.lastPlayedAt)])
        ..limit(limit));

  Stream<List<GameWithStatus>> watchRecentlyAdded({int limit = 20}) =>
      _watchGames((q) => q
        ..orderBy([(g) => OrderingTerm.desc(g.addedAt)])
        ..limit(limit));

  Stream<List<GameWithStatus>> watchAllGames({String? consoleId}) =>
      _watchGames((q) {
        if (consoleId != null) q.where((g) => g.consoleId.equals(consoleId));
        q.orderBy([(g) => OrderingTerm.asc(g.sortTitle)]);
      });

  Stream<List<GameWithStatus>> watchFavorites() =>
      _watchGames((q) => q.orderBy([(g) => OrderingTerm.asc(g.sortTitle)]),
          favoritesOnly: true);

  /// Local cover artwork path per game (cached files only; never remote).
  Stream<Map<int, String>> watchCoverPaths() =>
      (select(gameArtworks)..where((a) => a.type.equals('cover')))
          .watch()
          .map((rows) => {for (final r in rows) r.gameId: r.localPath});

  Stream<GameWithStatus?> watchGame(int gameId) {
    final q = select(games).join([
      leftOuterJoin(favorites, favorites.gameId.equalsExp(games.id)),
    ])
      ..where(games.id.equals(gameId));
    return q.watchSingleOrNull().map((r) => r == null
        ? null
        : GameWithStatus(r.readTable(games), r.readTableOrNull(favorites) != null));
  }

  /// Removes a game from the library only. Files on storage are untouched.
  Future<void> removeGameFromLibrary(int gameId) =>
      (delete(games)..where((g) => g.id.equals(gameId))).go();

  Future<List<GameFileRow>> filesForGame(int gameId) =>
      (select(gameFiles)..where((f) => f.gameId.equals(gameId))).get();

  Future<GameMetadataRow?> metadataForGame(int gameId) =>
      (select(gameMetadata)..where((m) => m.gameId.equals(gameId))).getSingleOrNull();

  Future<void> setFavorite(int gameId, bool favorite) async {
    if (favorite) {
      await into(favorites).insertOnConflictUpdate(
          FavoritesCompanion.insert(gameId: Value(gameId), addedAt: DateTime.now()));
    } else {
      await (delete(favorites)..where((f) => f.gameId.equals(gameId))).go();
    }
  }

  Stream<Map<String, int>> watchGameCountsByConsole() {
    final count = games.id.count();
    return (selectOnly(games)
          ..addColumns([games.consoleId, count])
          ..groupBy([games.consoleId]))
        .watch()
        .map((rows) => {
              for (final r in rows) r.read(games.consoleId)!: r.read(count) ?? 0,
            });
  }

  // ----------------------------------------------------------- emulators --

  /// Stores the result of an installed-package scan.
  Future<void> saveEmulatorDetection(Map<String, String?> installedVersions) {
    final now = DateTime.now();
    return batch((b) {
      for (final e in knownEmulators) {
        for (final pkg in e.packageIds) {
          final installed = installedVersions.containsKey(pkg);
          b.insert(
            emulatorAdapters,
            EmulatorAdaptersCompanion.insert(
              emulatorId: e.id,
              packageName: pkg,
              strategy: e.strategy.name,
              launchMechanism: const Value('android_intent'),
              installed: Value(installed),
              installedVersion: Value(installedVersions[pkg]),
              lastDetectedAt: Value(now),
            ),
            onConflict: DoUpdate(
              (old) => EmulatorAdaptersCompanion(
                installed: Value(installed),
                installedVersion: Value(installedVersions[pkg]),
                lastDetectedAt: Value(now),
              ),
              target: [emulatorAdapters.emulatorId, emulatorAdapters.packageName],
            ),
          );
        }
      }
    });
  }

  // --------------------------------------------------------- controllers --

  Future<void> recordControllers(List<InputDeviceInfo> controllers) {
    final now = DateTime.now();
    return batch((b) {
      for (final c in controllers.where((c) => c.isGameController)) {
        b.insert(
          controllerDevices,
          ControllerDevicesCompanion.insert(
            descriptor: c.descriptor.isEmpty ? 'id:${c.id}:${c.name}' : c.descriptor,
            name: c.name,
            vendorId: Value(c.vendorId),
            productId: Value(c.productId),
            controllerType: c.classes.contains('gamepad') ? 'gamepad' : 'joystick',
            hasVibrator: Value(c.hasVibrator),
            buttonsJson: Value(jsonEncode(c.buttons)),
            axesJson: Value(jsonEncode(c.axes)),
            firstSeenAt: now,
            lastSeenAt: now,
          ),
          onConflict: DoUpdate(
            (old) => ControllerDevicesCompanion(
              name: Value(c.name),
              hasVibrator: Value(c.hasVibrator),
              buttonsJson: Value(jsonEncode(c.buttons)),
              axesJson: Value(jsonEncode(c.axes)),
              lastSeenAt: Value(now),
            ),
            target: [controllerDevices.descriptor],
          ),
        );
      }
    });
  }

  Future<List<ControllerDeviceRow>> knownControllers() =>
      (select(controllerDevices)
            ..orderBy([(c) => OrderingTerm.desc(c.lastSeenAt)]))
          .get();

  // ------------------------------------------------------------- storage --

  Future<void> recordStorageVolumes(List<StorageVolumeInfo> volumes) async {
    final now = DateTime.now();
    await transaction(() async {
      await update(storageDevices)
          .write(const StorageDevicesCompanion(isConnected: Value(false)));
      for (final v in volumes) {
        await into(storageDevices).insert(
          StorageDevicesCompanion.insert(
            volumeId: v.id,
            description: v.description,
            kind: v.kind.name,
            isRemovable: v.isRemovable,
            totalBytes: Value(v.totalBytes),
            availableBytes: Value(v.availableBytes),
            isConnected: Value(v.isMounted),
            lastSeenAt: now,
          ),
          onConflict: DoUpdate(
            (old) => StorageDevicesCompanion(
              description: Value(v.description),
              totalBytes: Value(v.totalBytes),
              availableBytes: Value(v.availableBytes),
              isConnected: Value(v.isMounted),
              lastSeenAt: Value(now),
            ),
            target: [storageDevices.volumeId],
          ),
        );
      }
    });
  }

  Stream<List<StorageDeviceRow>> watchStorageDevices() =>
      (select(storageDevices)
            ..orderBy([
              (s) => OrderingTerm.desc(s.isConnected),
              (s) => OrderingTerm.desc(s.lastSeenAt),
            ]))
          .watch();

  // ----------------------------------------------------------- downloads --

  Stream<List<DownloadQueueRow>> watchDownloadQueue() =>
      (select(downloadQueue)..orderBy([(d) => OrderingTerm.desc(d.createdAt)]))
          .watch();

  // ------------------------------------------------------- compatibility --

  Future<List<DeviceCompatibilityRow>> compatibilityHistory({int limit = 50}) =>
      (select(deviceCompatibility)
            ..orderBy([(c) => OrderingTerm.desc(c.compatibilityDate)])
            ..limit(limit))
          .get();
}

/// Parses a stored tier name, defaulting to ENTRY.
PerformanceTier tierFromName(String name) => PerformanceTier.values
    .firstWhere((t) => t.name == name, orElse: () => PerformanceTier.entry);
