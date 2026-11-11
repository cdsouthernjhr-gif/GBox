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
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // One step per version; never drop user tables.
          // See docs/DATABASE_SCHEMA.md.
          if (from < 2) {
            await m.addColumn(games, games.regions);
            await m.addColumn(gameFiles, gameFiles.rootUri);
            await m.addColumn(gameFiles, gameFiles.lastModified);
            await m.addColumn(gameFiles, gameFiles.isPrimary);
            await m.addColumn(gameFiles, gameFiles.discNumber);
            await m.addColumn(gameFiles, gameFiles.headerStatus);
            await m.addColumn(gameFiles, gameFiles.headerDetail);
            await m.create(idxGameFilesRoot);
            await m.create(idxGameFilesGame);
          }
          if (from < 3) {
            await m.addColumn(controllerProfiles, controllerProfiles.calibrationJson);
          }
          if (from < 4) {
            await m.addColumn(downloadQueue, downloadQueue.filePath);
            await m.addColumn(downloadQueue, downloadQueue.consoleId);
            await m.addColumn(downloadQueue, downloadQueue.catalogJson);
            await m.addColumn(downloadQueue, downloadQueue.sha256);
            await m.addColumn(downloadQueue, downloadQueue.importedGameId);
          }
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
        SourceConnectorsCompanion.insert(
          id: 'gamebox_catalog',
          name: 'GAMEBOX catalogue',
          type: 'catalog',
          version: '1',
          description: const Value('JSON list of licensed games (docs/ONLINE_SOURCES.md).'),
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

  /// Library view with search, filters and sorting (Phase 2).
  /// [sort]: `title` | `recentlyPlayed` | `recentlyAdded`.
  Stream<List<GameWithStatus>> watchLibrary({
    String query = '',
    String? consoleId,
    bool favoritesOnly = false,
    bool missingOnly = false,
    String sort = 'title',
  }) {
    final words = query.trim().toLowerCase().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    // Each word must appear in the title (bound parameters, LIKE-escaped).
    final q2 = select(games).join([
      leftOuterJoin(favorites, favorites.gameId.equalsExp(games.id)),
    ]);
    for (final w in words) {
      q2.where(games.title.lower().like('%${_escapeLike(w)}%', escapeChar: r'\'));
    }
    if (consoleId != null) q2.where(games.consoleId.equals(consoleId));
    if (favoritesOnly) q2.where(favorites.gameId.isNotNull());
    if (missingOnly) q2.where(games.isMissing.equals(true));
    q2.orderBy(switch (sort) {
      'recentlyPlayed' => [
          OrderingTerm(expression: games.lastPlayedAt, mode: OrderingMode.desc, nulls: NullsOrder.last),
          OrderingTerm.asc(games.sortTitle),
        ],
      'recentlyAdded' => [OrderingTerm.desc(games.addedAt), OrderingTerm.asc(games.sortTitle)],
      _ => [OrderingTerm.asc(games.sortTitle)],
    });
    return q2.watch().map((rows) => [
          for (final r in rows)
            GameWithStatus(r.readTable(games), r.readTableOrNull(favorites) != null),
        ]);
  }

  static String _escapeLike(String s) =>
      s.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');

  Future<GameFileRow?> fileByUri(String uri) =>
      (select(gameFiles)..where((f) => f.uri.equals(uri))).getSingleOrNull();

  Future<List<GameFileRow>> filesPendingVerification() =>
      (select(gameFiles)..where((f) => f.headerStatus.isNull() & f.fileExists.equals(true))).get();

  Future<GameRow> gameById(int id) => (select(games)..where((g) => g.id.equals(id))).getSingle();

  Future<GameFileRow> fileById(int id) => (select(gameFiles)..where((f) => f.id.equals(id))).getSingle();

  Future<List<GameFileRow>> filesUnderRoot(String rootUri) =>
      (select(gameFiles)..where((f) => f.rootUri.equals(rootUri))).get();

  /// Inserts a game with its files (and optional cached cover) atomically.
  Future<int> insertGameWithFiles(
    GamesCompanion game,
    List<GameFilesCompanion> files, {
    String? coverPath,
  }) =>
      transaction(() async {
        final id = await into(games).insert(game);
        for (final f in files) {
          await into(gameFiles).insert(f.copyWith(gameId: Value(id)));
        }
        if (coverPath != null) await setCover(id, coverPath);
        return id;
      });

  /// Marks files present/absent and recomputes `games.is_missing`.
  Future<void> setFilesExist(Iterable<int> fileIds, bool exists) async {
    final ids = fileIds.toList();
    if (ids.isEmpty) return;
    await (update(gameFiles)..where((f) => f.id.isIn(ids)))
        .write(GameFilesCompanion(fileExists: Value(exists)));
    await refreshMissingFlags();
  }

  /// A game is missing when none of its files exist.
  Future<void> refreshMissingFlags() => customStatement(
        'UPDATE games SET is_missing = NOT EXISTS (SELECT 1 FROM game_files f '
        'WHERE f.game_id = games.id AND f.file_exists = 1)',
      );

  Future<void> updateFileVerification(
    int fileId, {
    String? sha1,
    String? crc32,
    int? size,
    String? headerStatus,
    String? headerDetail,
  }) =>
      (update(gameFiles)..where((f) => f.id.equals(fileId))).write(GameFilesCompanion(
        sha1: sha1 == null ? const Value.absent() : Value(sha1),
        crc32: crc32 == null ? const Value.absent() : Value(crc32),
        sizeBytes: size == null ? const Value.absent() : Value(size),
        headerStatus: headerStatus == null ? const Value.absent() : Value(headerStatus),
        headerDetail: headerDetail == null ? const Value.absent() : Value(headerDetail),
        lastVerifiedAt: Value(DateTime.now()),
      ));

  /// Other files with the same SHA-1 (exact duplicates).
  Future<List<GameFileRow>> duplicatesOf(GameFileRow file) {
    if (file.sha1 == null) {
      // Without a hash, same name + size is reported as a *possible* duplicate.
      return (select(gameFiles)
            ..where((f) =>
                f.id.equals(file.id).not() &
                f.displayPath.like('%${_escapeLike(file.displayPath.split('/').last)}', escapeChar: r'\') &
                (file.sizeBytes == null ? const Constant(false) : f.sizeBytes.equals(file.sizeBytes!))))
          .get();
    }
    return (select(gameFiles)..where((f) => f.sha1.equals(file.sha1!) & f.id.equals(file.id).not())).get();
  }

  Future<void> setCover(int gameId, String localPath, {String? provider}) => transaction(() async {
        await (delete(gameArtworks)..where((a) => a.gameId.equals(gameId) & a.type.equals('cover'))).go();
        await into(gameArtworks).insert(GameArtworksCompanion.insert(
          gameId: gameId,
          type: 'cover',
          localPath: localPath,
          provider: Value(provider ?? 'local'),
          fetchedAt: DateTime.now(),
        ));
      });

  Future<void> removeCover(int gameId) =>
      (delete(gameArtworks)..where((a) => a.gameId.equals(gameId) & a.type.equals('cover'))).go();

  /// Manual metadata editing. Marks the metadata as user-edited so automatic
  /// scraping (Phase 5) will not overwrite it.
  Future<void> saveManualMetadata(
    int gameId, {
    required String title,
    required String sortTitle,
    String? developer,
    String? publisher,
    String? releaseDate,
    String? genre,
    String? description,
  }) =>
      transaction(() async {
        await (update(games)..where((g) => g.id.equals(gameId)))
            .write(GamesCompanion(title: Value(title), sortTitle: Value(sortTitle)));
        String? n(String? s) => (s == null || s.trim().isEmpty) ? null : s.trim();
        await into(gameMetadata).insertOnConflictUpdate(GameMetadataCompanion.insert(
          gameId: Value(gameId),
          developer: Value(n(developer)),
          publisher: Value(n(publisher)),
          releaseDate: Value(n(releaseDate)),
          genre: Value(n(genre)),
          description: Value(n(description)),
          provider: const Value('manual'),
          editedManually: const Value(true),
          fetchedAt: Value(DateTime.now()),
        ));
      });

  // ------------------------------------------------- launching (Phase 3) --

  /// Default emulator (and options such as the RetroArch core) for a console.
  Future<EmulatorProfileRow?> defaultLaunchProfile(String consoleId) =>
      (select(emulatorProfiles)
            ..where((p) => p.consoleId.equals(consoleId) & p.isDefault.equals(true))
            ..limit(1))
          .getSingleOrNull();

  Future<void> setDefaultLaunchProfile(String consoleId, String emulatorId, Map<String, String> options) =>
      transaction(() async {
        await (delete(emulatorProfiles)..where((p) => p.consoleId.equals(consoleId) & p.isDefault.equals(true))).go();
        await into(emulatorProfiles).insert(EmulatorProfilesCompanion.insert(
          emulatorId: emulatorId,
          consoleId: Value(consoleId),
          name: 'Default for $consoleId',
          settingsJson: Value(jsonEncode(options)),
          isDefault: const Value(true),
        ));
      });

  Stream<List<EmulatorProfileRow>> watchDefaultLaunchProfiles() =>
      (select(emulatorProfiles)..where((p) => p.isDefault.equals(true))).watch();

  /// Records a launch: history row + last played + play count.
  Future<int> startPlaySession(int gameId, String emulatorId, DateTime at) => transaction(() async {
        final id = await into(gameHistory).insert(GameHistoryCompanion.insert(
          gameId: gameId,
          emulatorId: Value(emulatorId),
          startedAt: at,
        ));
        await customStatement(
          'UPDATE games SET last_played_at = ?, play_count = play_count + 1 WHERE id = ?',
          [at.millisecondsSinceEpoch ~/ 1000, gameId],
        );
        return id;
      });

  /// Closes a session when the user returns to GAMEBOX. The duration is the
  /// time GAMEBOX was in the background, i.e. an upper bound of play time.
  Future<void> endPlaySession(int sessionId, DateTime at, {String exitStatus = 'returned'}) async {
    final row = await (select(gameHistory)..where((h) => h.id.equals(sessionId))).getSingleOrNull();
    if (row == null || row.endedAt != null) return;
    await (update(gameHistory)..where((h) => h.id.equals(sessionId))).write(GameHistoryCompanion(
      endedAt: Value(at),
      durationSeconds: Value(at.difference(row.startedAt).inSeconds.clamp(0, 1 << 31)),
      exitStatus: Value(exitStatus),
    ));
  }

  Future<List<GameHistoryRow>> historyForGame(int gameId, {int limit = 10}) =>
      (select(gameHistory)
            ..where((h) => h.gameId.equals(gameId))
            ..orderBy([(h) => OrderingTerm.desc(h.startedAt)])
            ..limit(limit))
          .get();

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

  // ----------------------------------------------------------- sources --

  Stream<List<GameSourceRow>> watchSources() =>
      (select(gameSources)..orderBy([(s) => OrderingTerm.asc(s.name)])).watch();

  Future<GameSourceRow> sourceById(int id) => (select(gameSources)..where((s) => s.id.equals(id))).getSingle();

  Future<int> addSource(GameSourcesCompanion s) => into(gameSources).insert(s);

  Future<void> updateSourceStatus(int id, String status) =>
      (update(gameSources)..where((s) => s.id.equals(id))).write(GameSourcesCompanion(
        connectionStatus: Value(status),
        lastCheckedAt: Value(DateTime.now()),
      ));

  Future<void> deleteSource(int id) => (delete(gameSources)..where((s) => s.id.equals(id))).go();

  // ----------------------------------------------------------- downloads --

  Future<DownloadQueueRow> downloadById(int id) =>
      (select(downloadQueue)..where((d) => d.id.equals(id))).getSingle();

  Future<DownloadQueueRow?> nextQueuedDownload() => (select(downloadQueue)
        ..where((d) => d.status.equals('queued'))
        ..orderBy([(d) => OrderingTerm.asc(d.createdAt), (d) => OrderingTerm.asc(d.id)])
        ..limit(1))
      .getSingleOrNull();

  Future<void> updateDownload(int id, DownloadQueueCompanion c) =>
      (update(downloadQueue)..where((d) => d.id.equals(id)))
          .write(c.copyWith(updatedAt: Value(DateTime.now())));

  Future<void> deleteDownload(int id) => (delete(downloadQueue)..where((d) => d.id.equals(id))).go();

  Stream<List<DownloadHistoryRow>> watchDownloadHistory({int limit = 50}) => (select(downloadHistory)
        ..orderBy([(h) => OrderingTerm.desc(h.finishedAt)])
        ..limit(limit))
      .watch();

  /// Metadata from an online provider (e.g. a catalogue). Never overwrites
  /// metadata the user edited manually.
  Future<void> saveProviderMetadata(
    int gameId, {
    required String provider,
    String? description,
    String? developer,
    String? releaseDate,
    String? providerId,
  }) async {
    final existing = await metadataForGame(gameId);
    if (existing?.editedManually == true) return;
    await into(gameMetadata).insertOnConflictUpdate(GameMetadataCompanion.insert(
      gameId: Value(gameId),
      description: Value(description),
      developer: Value(developer),
      releaseDate: Value(releaseDate),
      provider: Value(provider),
      providerId: Value(providerId),
      fetchedAt: Value(DateTime.now()),
    ));
  }

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
