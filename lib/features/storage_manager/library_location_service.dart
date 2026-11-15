import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../core/errors/app_logger.dart';
import '../../core/rom/scan_planner.dart';
import '../../core/services/platform_gateway.dart';
import '../../core/storage/gamebox_layout.dart';
import '../../data/repositories/settings_repository.dart';
import '../save_manager/save_service.dart';

/// A file placed in the library location.
class PlacedFile {
  const PlacedFile({required this.location, required this.name, required this.dirSegments, required this.size});

  /// Local path or SAF document URI.
  final String location;
  final String name;

  /// Folders relative to the base, e.g. `[ROMs, nes]`.
  final List<String> dirSegments;
  final int size;

  bool get isDocument => location.startsWith('content://');

  ScannedEntry toEntry() => ScannedEntry(uri: location, name: name, dirSegments: dirSegments, size: size);
}

enum LocationMode {
  /// Device storage root with all-files access (`/storage/emulated/0`).
  /// Recommended: RetroArch and other emulators read `ROMs/` directly.
  device,

  /// A folder the user picked with the system folder picker (e.g. on USB).
  tree,

  /// GAMEBOX's app folder. Always works, but is deleted with the app and
  /// unreadable for other apps on Android 11+.
  app,
}

/// Where GAMEBOX keeps games (`ROMs/<system>`) and its own data
/// (`GAMEBOX/…`), and the file operations that keep that place organised.
class LibraryLocationService {
  LibraryLocationService({
    required this._gateway,
    required this._settings,
    required this._appRoot,
    required this._saves,
    required this._installedEmulators,
    this._appBases,
  });

  final PlatformGateway _gateway;
  final SettingsRepository _settings;

  /// `<app folder>/GAMEBOX` on the primary volume.
  final Future<String> Function() _appRoot;
  final SaveService _saves;
  final List<String> Function() _installedEmulators;

  /// App folders on every volume (`…/Android/data/<pkg>/files`), used to
  /// find the public root of removable volumes.
  final Future<List<String>> Function()? _appBases;

  final ValueNotifier<StorageAccessStatus> access = ValueNotifier(StorageAccessStatus.unknown);

  Future<StorageAccessStatus> refreshAccess() async {
    try {
      access.value = await _gateway.storageAccess();
    } catch (e, s) {
      AppLogger.instance.error('Reading storage access failed', e, s);
    }
    return access.value;
  }

  /// Opens the system screen / asks for the storage permission.
  Future<String> requestAccess() => _gateway.requestStorageAccess();

  String? get treeUri {
    final v = _settings.state.value.libraryLocation;
    return v != null && v.startsWith('content://') ? v : null;
  }

  LocationMode get mode {
    if (treeUri != null) return LocationMode.tree;
    final a = access.value;
    return a.granted && a.publicRoot != null ? LocationMode.device : LocationMode.app;
  }

  /// Other apps (RetroArch, …) can read the games.
  bool get isPublic => mode != LocationMode.app;

  /// GAMEBOX's app folder base (`…/files`), parent of the app GAMEBOX root.
  Future<String> appBase() async => Directory(await _appRoot()).parent.path;

  /// Local base path, or null for a picked (SAF) folder.
  Future<String?> localBase() async => switch (mode) {
        LocationMode.device => access.value.publicRoot,
        LocationMode.app => appBase(),
        LocationMode.tree => null,
      };

  /// Human-readable location of [rel] (relative to the base).
  Future<String> describe([String rel = '']) async {
    final base = switch (mode) {
      LocationMode.tree => _treeLabel(treeUri!),
      LocationMode.device => _deviceLabel(access.value.publicRoot!),
      LocationMode.app => await appBase(),
    };
    return rel.isEmpty ? base : '$base/$rel';
  }

  static String _deviceLabel(String root) => root.endsWith('/emulated/0') ? 'Internal storage' : root;

  static String _treeLabel(String uri) {
    final decoded = Uri.decodeComponent(uri);
    final i = decoded.indexOf('/tree/');
    final id = i >= 0 ? decoded.substring(i + 6) : decoded;
    return id.startsWith('primary:') ? 'Internal storage/${id.substring(8)}' : id;
  }

  /// Creates every folder of the layout. Returns the folders that could
  /// not be created (empty when all exist).
  Future<List<String>> ensureStructure() async {
    final folders = gameboxFolders();
    final tree = treeUri;
    if (tree != null) {
      final r = await _gateway.ensureTreeDirs(tree, folders);
      return [for (final f in (r['failed'] as List?) ?? const []) '$f'];
    }
    final base = (await localBase())!;
    final failed = <String>[];
    for (final f in folders) {
      try {
        await Directory('$base/$f').create(recursive: true);
      } catch (e) {
        failed.add('$f: $e');
      }
    }
    return failed;
  }

  /// Uses the picked folder [tree] (e.g. on a USB drive): creates the layout
  /// there, adds it to the game folders and registers save folders.
  Future<List<String>> choose(String tree) async {
    await _settings.set(SettingsKeys.libraryLocation, tree);
    final folders = _settings.state.value.romFolders;
    if (!folders.contains(tree)) await _settings.setRomFolders([...folders, tree]);
    await _waitFor(() => treeUri == tree && _settings.state.value.romFolders.contains(tree));
    final failed = await ensureStructure();
    await registerSaveFolders();
    return failed;
  }

  /// Stops using a picked folder: device storage when access is granted,
  /// else the app folder. Nothing is moved or deleted.
  Future<List<String>> useDefault() async {
    await _settings.set(SettingsKeys.libraryLocation, '');
    await _waitFor(() => treeUri == null);
    final failed = await ensureStructure();
    if (isPublic) await registerSaveFolders();
    return failed;
  }

  Future<void> _waitFor(bool Function() done) async {
    for (var i = 0; i < 50 && !done(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  /// Local folders the library scans for this location: `ROMs/` on device
  /// storage (and on removable volumes that have one) and in the app folder.
  Future<List<String>> localScanRoots() async {
    final roots = <String>{'${await appBase()}/$romsDir'};
    if (access.value.granted) {
      final primary = access.value.publicRoot;
      if (primary != null) roots.add('$primary/$romsDir');
      for (final v in await publicVolumeRoots()) {
        if (await Directory('$v/$romsDir').exists()) roots.add('$v/$romsDir');
      }
    }
    return roots.toList();
  }

  /// Public roots of all volumes (`/storage/emulated/0`, `/storage/XXXX-XXXX`).
  Future<List<String>> publicVolumeRoots() async {
    final out = <String>{if (access.value.publicRoot != null) access.value.publicRoot!};
    for (final b in await (_appBases ?? () async => <String>[])()) {
      final i = b.indexOf('/Android/data/');
      if (i > 0) out.add(b.substring(0, i));
    }
    return out.toList();
  }

  /// Save Manager identity of an emulator's suggested save folder.
  /// Picked folders use `<tree>#<relative path>`; only that part of the tree
  /// is scanned.
  Future<String> saveFolderUri(SaveLayout l) async =>
      mode == LocationMode.tree ? '$treeUri#${l.root}' : '${await localBase()}/${l.root}';

  /// Registers the suggested save folder of each installed emulator with the
  /// Save Manager. Returns how many were added.
  Future<int> registerSaveFolders() async {
    final installed = _installedEmulators().toSet();
    final existing = {for (final f in _settings.state.value.saveFolders) f.uri};
    final add = <SaveFolder>[];
    for (final l in saveLayouts) {
      if (!installed.contains(l.emulatorId)) continue;
      final uri = await saveFolderUri(l);
      if (existing.add(uri)) add.add(SaveFolder(uri, l.emulatorId));
    }
    await _saves.addFolders(add);
    return add.length;
  }

  /// Moves (or with [copy], copies) the local file [localPath] into [relDir]
  /// (e.g. `ROMs/nes`). Never overwrites: a free name is chosen.
  Future<PlacedFile> place(String localPath, String relDir, {bool copy = false}) async {
    final src = File(localPath);
    final name = src.uri.pathSegments.last;
    final size = await src.length();
    final dirs = relDir.split('/').where((s) => s.isNotEmpty).toList();
    final tree = treeUri;
    if (tree != null) {
      final uri = await _gateway.writeToTree(tree, relDir, name, localPath);
      if (!copy) await src.delete();
      return PlacedFile(location: uri, name: _nameOfDocument(uri, name), dirSegments: dirs, size: size);
    }
    final dir = Directory('${await localBase()}/$relDir');
    await dir.create(recursive: true);
    final dest = _freeFile(dir.path, name);
    if (copy) {
      await src.copy(dest.path);
    } else {
      await _move(src, dest);
    }
    return PlacedFile(location: dest.path, name: dest.uri.pathSegments.last, dirSegments: dirs, size: size);
  }

  /// Moves every file under the local folder [localDir] into [relDir]
  /// (e.g. `ROMs/psx/My Game`), keeping sub-folders; the local folder is
  /// removed afterwards (kept with [copy]).
  Future<List<PlacedFile>> placeFolder(String localDir, String relDir, {bool copy = false}) async {
    final src = Directory(localDir);
    final files = [await for (final e in src.list(recursive: true, followLinks: false)) if (e is File) e];
    final placed = <PlacedFile>[];
    final tree = treeUri;
    if (tree == null) {
      final base = (await localBase())!;
      final target = _freeDir('$base/$relDir');
      await target.parent.create(recursive: true);
      var renamed = false;
      if (!copy) {
        try {
          await src.rename(target.path);
          renamed = true;
        } on FileSystemException {
          // Different volume: copy, then remove.
        }
      }
      if (!renamed) {
        for (final f in files) {
          final rel = f.path.substring(src.path.length + 1);
          final out = File('${target.path}/$rel');
          await out.parent.create(recursive: true);
          await f.copy(out.path);
        }
        if (!copy) await src.delete(recursive: true);
      }
      final baseSegs = target.path.substring(base.length + 1).split('/');
      await for (final e in target.list(recursive: true, followLinks: false)) {
        if (e is! File) continue;
        final rel = e.path.substring(target.path.length + 1).split('/');
        placed.add(PlacedFile(
          location: e.path,
          name: rel.last,
          dirSegments: [...baseSegs, ...rel.sublist(0, rel.length - 1)],
          size: await e.length(),
        ));
      }
      return placed;
    }
    // Picked folder: a free folder name, then copy file by file.
    final relSegs = relDir.split('/').where((s) => s.isNotEmpty).toList();
    final parent = relSegs.sublist(0, relSegs.length - 1).join('/');
    final taken = {for (final n in await _gateway.listTreeNames(tree, parent)) n.toLowerCase()};
    var leaf = relSegs.last;
    for (var n = 2; taken.contains(leaf.toLowerCase()); n++) {
      leaf = '${relSegs.last} ($n)';
    }
    final baseSegs = [...relSegs.sublist(0, relSegs.length - 1), leaf];
    for (final f in files) {
      final rel = f.path.substring(src.path.length + 1).split('/');
      final dirs = [...baseSegs, ...rel.sublist(0, rel.length - 1)];
      final uri = await _gateway.writeToTree(tree, dirs.join('/'), rel.last, f.path);
      placed.add(PlacedFile(location: uri, name: _nameOfDocument(uri, rel.last), dirSegments: dirs, size: await f.length()));
    }
    if (!copy) await src.delete(recursive: true);
    return placed;
  }

  /// Deletes a placed file or document (used when a download is deleted).
  Future<bool> delete(String location) => location.startsWith('content://')
      ? _gateway.deleteFile(location)
      : File(location).delete().then((_) => true, onError: (_) => false);

  static String _nameOfDocument(String uri, String fallback) {
    final decoded = Uri.decodeComponent(uri);
    final last = decoded.split('/').last;
    return last.isEmpty ? fallback : last;
  }

  static File _freeFile(String dir, String name) {
    final dot = name.lastIndexOf('.');
    final stem = dot > 0 ? name.substring(0, dot) : name;
    final ext = dot > 0 ? name.substring(dot) : '';
    var f = File('$dir/$name');
    for (var n = 2; f.existsSync(); n++) {
      f = File('$dir/$stem ($n)$ext');
    }
    return f;
  }

  static Directory _freeDir(String path) {
    var d = Directory(path);
    for (var n = 2; d.existsSync(); n++) {
      d = Directory('$path ($n)');
    }
    return d;
  }

  static Future<void> _move(File src, File dest) async {
    try {
      await src.rename(dest.path);
    } on FileSystemException {
      await src.copy(dest.path);
      await src.delete();
    }
  }

  /// Which BIOS files are present in each `GAMEBOX/BIOS/<CONSOLE>` folder.
  Future<List<BiosStatus>> biosStatus() async {
    final out = <BiosStatus>[];
    final tree = treeUri;
    final base = tree == null ? await localBase() : null;
    for (final b in biosInfo) {
      List<String> names;
      try {
        if (tree != null) {
          names = await _gateway.listTreeNames(tree, b.dir);
        } else {
          final d = Directory('$base/${b.dir}');
          names = !await d.exists()
              ? const []
              : [await for (final e in d.list()) if (e is File) e.uri.pathSegments.last];
        }
      } catch (e, s) {
        AppLogger.instance.error('Reading ${b.dir} failed', e, s);
        names = const [];
      }
      out.add(BiosStatus(b, names.where((n) => !n.startsWith('.')).toList()));
    }
    return out;
  }
}
