// Drift column checks reference their own column getter by design.
// ignore_for_file: recursive_getters
// GAMEBOX database schema (Drift). See docs/DATABASE_SCHEMA.md.
//
// ROM binaries are never stored here: only file references and metadata.
import 'package:drift/drift.dart';

// ---------------------------------------------------------------- devices --

@DataClassName('DeviceRow')
class Devices extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Stable key derived from manufacturer/model/build fingerprint.
  TextColumn get deviceKey => text().unique()();
  TextColumn get manufacturer => text().nullable()();
  TextColumn get model => text().nullable()();
  TextColumn get deviceName => text().nullable()();
  TextColumn get androidVersion => text().nullable()();
  IntColumn get sdkInt => integer().nullable()();
  TextColumn get buildFingerprint => text().nullable()();
  DateTimeColumn get firstSeenAt => dateTime()();
  DateTimeColumn get lastSeenAt => dateTime()();
}

@DataClassName('HardwareProfileRow')
@TableIndex(name: 'idx_hw_profiles_device', columns: {#deviceId, #scannedAt})
class DeviceHardwareProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get deviceId =>
      integer().references(Devices, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get scannedAt => dateTime()();
  TextColumn get tier => text()();
  TextColumn get confidence => text()();
  TextColumn get abis => text()();
  TextColumn get cpuDescription => text().nullable()();
  IntColumn get cpuCores => integer().nullable()();
  IntColumn get totalRamBytes => integer().nullable()();
  TextColumn get glRenderer => text().nullable()();
  TextColumn get glEsVersion => text().nullable()();
  BoolColumn get vulkanSupported => boolean().nullable()();
  IntColumn get displayWidth => integer().nullable()();
  IntColumn get displayHeight => integer().nullable()();

  /// Full HardwareProfile as JSON for forward compatibility.
  TextColumn get rawJson => text()();
}

/// Compatibility knowledge base. `source` separates (A) detected hardware,
/// (B) community reports and (C) verified GAMEBOX results.
@DataClassName('DeviceCompatibilityRow')
@TableIndex(name: 'idx_compat_model', columns: {#manufacturer, #model})
class DeviceCompatibility extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get source => text().check(
      source.isIn(const ['detected', 'community', 'verified']))();
  TextColumn get manufacturer => text()();
  TextColumn get model => text()();
  TextColumn get chipset => text().nullable()();
  TextColumn get cpuArchitecture => text().nullable()();
  TextColumn get cpuCharacteristics => text().nullable()();
  TextColumn get gpu => text().nullable()();
  IntColumn get ramBytes => integer().nullable()();
  TextColumn get androidVersion => text().nullable()();
  TextColumn get graphicsApi => text().nullable()();
  TextColumn get emulatorId => text().nullable()();
  TextColumn get consoleId => text().nullable()();
  TextColumn get testedGame => text().nullable()();
  TextColumn get testResult => text().nullable()();
  TextColumn get performanceNotes => text().nullable()();
  TextColumn get knownLimitations => text().nullable()();
  DateTimeColumn get compatibilityDate => dateTime()();

  /// Identifier of the imported database bundle this row came from, if any.
  TextColumn get importBatch => text().nullable()();
}

@DataClassName('CompatibilityTestResultRow')
class CompatibilityTestResults extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get deviceId =>
      integer().references(Devices, #id, onDelete: KeyAction.cascade)();
  TextColumn get emulatorId => text().nullable().references(Emulators, #id)();
  TextColumn get consoleId => text().references(Consoles, #id)();
  IntColumn get gameId => integer()
      .nullable()
      .references(Games, #id, onDelete: KeyAction.setNull)();
  TextColumn get result => text().check(result.isIn(const [
        'excellent', 'good', 'limited', 'unsupported', 'notTested'
      ]))();
  TextColumn get source =>
      text().check(source.isIn(const ['local', 'community', 'verified']))();
  TextColumn get notes => text().nullable()();
  BoolColumn get consentToShare =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get submitted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get testedAt => dateTime()();
}

// ------------------------------------------------------ consoles/emulators --

@DataClassName('ConsoleRow')
class Consoles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get manufacturer => text()();
  TextColumn get category => text()();
  TextColumn get folderName => text()();

  /// Comma-separated lower-case extensions.
  TextColumn get extensions => text()();
  TextColumn get minTier => text()();
  TextColumn get recommendedTier => text()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('EmulatorRow')
class Emulators extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get license => text()();
  TextColumn get strategy => text()();
  BoolColumn get requiresArm64 => boolean().withDefault(const Constant(false))();
  IntColumn get minSdk => integer().nullable()();
  TextColumn get consoleIds => text()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('EmulatorProfileRow')
class EmulatorProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get emulatorId =>
      text().references(Emulators, #id, onDelete: KeyAction.cascade)();
  TextColumn get consoleId => text().nullable().references(Consoles, #id)();
  TextColumn get name => text()();
  TextColumn get settingsJson => text().withDefault(const Constant('{}'))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
}

@DataClassName('EmulatorAdapterRow')
class EmulatorAdapters extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get emulatorId =>
      text().references(Emulators, #id, onDelete: KeyAction.cascade)();
  TextColumn get packageName => text()();
  TextColumn get strategy => text()();
  TextColumn get launchMechanism => text().nullable()();
  TextColumn get installedVersion => text().nullable()();
  BoolColumn get installed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastDetectedAt => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {emulatorId, packageName}
      ];
}

// ------------------------------------------------------------------ games --

@DataClassName('GameRow')
@TableIndex(name: 'idx_games_console', columns: {#consoleId})
@TableIndex(name: 'idx_games_last_played', columns: {#lastPlayedAt})
class Games extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get sortTitle => text()();
  TextColumn get consoleId => text().references(Consoles, #id)();
  TextColumn get preferredEmulatorId =>
      text().nullable().references(Emulators, #id)();
  DateTimeColumn get addedAt => dateTime()();
  DateTimeColumn get lastPlayedAt => dateTime().nullable()();
  IntColumn get playCount => integer().withDefault(const Constant(0))();
  BoolColumn get isMissing => boolean().withDefault(const Constant(false))();

  /// Comma-separated regions parsed from the file name (schema v2).
  TextColumn get regions => text().nullable()();
}

@DataClassName('GameFileRow')
@TableIndex(name: 'idx_game_files_hash', columns: {#sha1})
@TableIndex(name: 'idx_game_files_root', columns: {#rootUri})
@TableIndex(name: 'idx_game_files_game', columns: {#gameId})
class GameFiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get gameId =>
      integer().references(Games, #id, onDelete: KeyAction.cascade)();

  /// SAF document URI or absolute path.
  TextColumn get uri => text().unique()();
  TextColumn get displayPath => text()();
  TextColumn get extension => text()();
  IntColumn get sizeBytes => integer().nullable()();
  TextColumn get sha1 => text().nullable()();
  TextColumn get crc32 => text().nullable()();
  IntColumn get storageDeviceId => integer()
      .nullable()
      .references(StorageDevices, #id, onDelete: KeyAction.setNull)();
  BoolColumn get fileExists => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastVerifiedAt => dateTime().nullable()();

  // ---- schema v2 ----
  /// Scan root (SAF tree URI or directory path) the file was found under;
  /// null for manually imported files.
  TextColumn get rootUri => text().nullable()();
  IntColumn get lastModified => integer().nullable()();
  BoolColumn get isPrimary => boolean().withDefault(const Constant(true))();
  IntColumn get discNumber => integer().nullable()();

  /// valid | invalid | notChecked (see rom_header_validator.dart).
  TextColumn get headerStatus => text().nullable()();
  TextColumn get headerDetail => text().nullable()();
}

@DataClassName('GameMetadataRow')
class GameMetadata extends Table {
  IntColumn get gameId =>
      integer().references(Games, #id, onDelete: KeyAction.cascade)();
  TextColumn get description => text().nullable()();
  TextColumn get developer => text().nullable()();
  TextColumn get publisher => text().nullable()();
  TextColumn get releaseDate => text().nullable()();
  TextColumn get genre => text().nullable()();
  IntColumn get players => integer().nullable()();
  TextColumn get provider => text().nullable()();
  TextColumn get providerId => text().nullable()();
  BoolColumn get editedManually =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get fetchedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {gameId};
}

@DataClassName('GameArtworkRow')
class GameArtworks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get gameId =>
      integer().references(Games, #id, onDelete: KeyAction.cascade)();
  TextColumn get type =>
      text().check(type.isIn(const ['cover', 'screenshot', 'background']))();
  TextColumn get localPath => text()();
  TextColumn get sourceUrl => text().nullable()();
  TextColumn get provider => text().nullable()();
  DateTimeColumn get fetchedAt => dateTime()();
}

@DataClassName('FavoriteRow')
class Favorites extends Table {
  IntColumn get gameId =>
      integer().references(Games, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get addedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {gameId};
}

@DataClassName('GameHistoryRow')
@TableIndex(name: 'idx_history_started', columns: {#startedAt})
class GameHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get gameId =>
      integer().references(Games, #id, onDelete: KeyAction.cascade)();
  TextColumn get emulatorId => text().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  IntColumn get durationSeconds => integer().nullable()();
  TextColumn get exitStatus => text().nullable()();
}

// ------------------------------------------------------------ controllers --

@DataClassName('ControllerDeviceRow')
class ControllerDevices extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get descriptor => text().unique()();
  TextColumn get name => text()();
  IntColumn get vendorId => integer().nullable()();
  IntColumn get productId => integer().nullable()();
  TextColumn get controllerType => text()();
  BoolColumn get hasVibrator => boolean().withDefault(const Constant(false))();
  TextColumn get buttonsJson => text().withDefault(const Constant('[]'))();
  TextColumn get axesJson => text().withDefault(const Constant('[]'))();
  IntColumn get assignedPlayer => integer().nullable()();
  DateTimeColumn get firstSeenAt => dateTime()();
  DateTimeColumn get lastSeenAt => dateTime()();
}

@DataClassName('ControllerProfileRow')
class ControllerProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get controllerDescriptor => text().nullable()();
  TextColumn get consoleId => text().nullable().references(Consoles, #id)();
  RealColumn get deadZone => real().withDefault(const Constant(0.15))();
  RealColumn get triggerThreshold => real().withDefault(const Constant(0.5))();
  BoolColumn get vibrationEnabled =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  /// Per-axis centre/min/max captured by the calibration screen (schema v3).
  TextColumn get calibrationJson => text().nullable()();
}

@DataClassName('ControllerMappingRow')
class ControllerMappings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId => integer()
      .references(ControllerProfiles, #id, onDelete: KeyAction.cascade)();

  /// Logical action, e.g. `A`, `B`, `START`, `DPAD_UP`, `LEFT_STICK_X`.
  TextColumn get action => text()();
  IntColumn get keyCode => integer().nullable()();
  IntColumn get axis => integer().nullable()();
  IntColumn get axisDirection => integer().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {profileId, action}
      ];
}

// ---------------------------------------------------------------- storage --

@DataClassName('StorageDeviceRow')
class StorageDevices extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get volumeId => text().unique()();
  TextColumn get description => text()();
  TextColumn get kind => text()();

  /// Persisted SAF tree URI granted by the user, if any.
  TextColumn get treeUri => text().nullable()();
  BoolColumn get isRemovable => boolean()();
  IntColumn get totalBytes => integer().nullable()();
  IntColumn get availableBytes => integer().nullable()();
  BoolColumn get isConnected => boolean().withDefault(const Constant(true))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSeenAt => dateTime()();
}

// ---------------------------------------------------------- online sources --

@DataClassName('GameSourceRow')
class GameSources extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get url => text()();
  TextColumn get category => text().nullable()();
  TextColumn get type => text().check(type.isIn(const [
        'direct_url', 'homebrew_repo', 'public_domain_repo',
        'authorized_distribution', 'personal_cloud', 'user_hosting',
        'custom_http_api'
      ]))();
  TextColumn get description => text().nullable()();
  TextColumn get authType => text().withDefault(const Constant('none'))();
  TextColumn get connectorId =>
      text().nullable().references(SourceConnectors, #id)();
  TextColumn get connectionStatus =>
      text().withDefault(const Constant('unknown'))();
  DateTimeColumn get lastCheckedAt => dateTime().nullable()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
}

@DataClassName('SourceConnectorRow')
class SourceConnectors extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get version => text()();
  TextColumn get description => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DownloadQueueRow')
@TableIndex(name: 'idx_download_status', columns: {#status})
class DownloadQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sourceId => integer()
      .nullable()
      .references(GameSources, #id, onDelete: KeyAction.setNull)();
  TextColumn get name => text()();
  TextColumn get url => text()();
  TextColumn get destination => text()();
  IntColumn get totalBytes => integer().nullable()();
  IntColumn get downloadedBytes => integer().withDefault(const Constant(0))();
  TextColumn get status => text().check(status.isIn(const [
        'queued', 'downloading', 'paused', 'completed', 'failed', 'cancelled'
      ]))();
  TextColumn get expectedHash => text().nullable()();
  TextColumn get hashAlgorithm => text().nullable()();
  TextColumn get errorMessage => text().nullable()();
  IntColumn get retries => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  // ---- schema v4 ----
  /// Final file path once the server named the file (`<path>.part` while
  /// downloading). [destination] is the target directory.
  TextColumn get filePath => text().nullable()();

  /// Console to import as (from a catalogue entry or chosen by the user).
  TextColumn get consoleId => text().nullable()();

  /// Catalogue entry JSON (title, licence, description, cover) for metadata.
  TextColumn get catalogJson => text().nullable()();

  /// SHA-256 computed while downloading.
  TextColumn get sha256 => text().nullable()();

  /// Game id once imported into the library.
  IntColumn get importedGameId => integer().nullable()();
}

@DataClassName('DownloadHistoryRow')
class DownloadHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sourceId => integer()
      .nullable()
      .references(GameSources, #id, onDelete: KeyAction.setNull)();
  TextColumn get name => text()();
  TextColumn get url => text()();
  TextColumn get destination => text()();
  IntColumn get sizeBytes => integer().nullable()();
  TextColumn get sha256 => text().nullable()();
  TextColumn get status => text()();
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get finishedAt => dateTime()();
}

// ------------------------------------------------------------------ saves --

@DataClassName('SaveStateRow')
class SaveStates extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get gameId =>
      integer().references(Games, #id, onDelete: KeyAction.cascade)();
  TextColumn get emulatorId => text().nullable()();

  /// `state` (emulator save state), `native` (in-game save) or `memcard`.
  TextColumn get kind =>
      text().check(kind.isIn(const ['state', 'native', 'memcard']))();
  IntColumn get slot => integer().nullable()();
  TextColumn get path => text()();
  IntColumn get sizeBytes => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

@DataClassName('SaveBackupRow')
class SaveBackups extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get gameId => integer()
      .nullable()
      .references(Games, #id, onDelete: KeyAction.setNull)();
  IntColumn get saveStateId => integer()
      .nullable()
      .references(SaveStates, #id, onDelete: KeyAction.setNull)();
  TextColumn get backupPath => text()();
  IntColumn get sizeBytes => integer().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

// ------------------------------------------------------------ performance --

@DataClassName('BenchmarkRow')
class Benchmarks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get deviceId =>
      integer().references(Devices, #id, onDelete: KeyAction.cascade)();
  TextColumn get emulatorId => text().nullable()();
  TextColumn get consoleId => text().nullable()();
  IntColumn get gameId => integer()
      .nullable()
      .references(Games, #id, onDelete: KeyAction.setNull)();
  TextColumn get benchmarkType => text()();
  RealColumn get averageFps => real().nullable()();
  RealColumn get minimumFps => real().nullable()();
  RealColumn get score => real().nullable()();
  IntColumn get durationMs => integer()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get ranAt => dateTime()();
}

// --------------------------------------------------------------- settings --

@DataClassName('AppSettingRow')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}
