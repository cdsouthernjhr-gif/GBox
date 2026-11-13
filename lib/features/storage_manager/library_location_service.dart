import 'dart:io';

import '../../core/errors/app_logger.dart';
import '../../core/rom/scan_planner.dart';
import '../../core/services/platform_gateway.dart';
import '../../core/storage/gamebox_layout.dart';
import '../../data/repositories/settings_repository.dart';
import '../save_manager/save_service.dart';

/// A file placed in the library location.
class PlacedFile {
  const PlacedFile({required this.location, required this.name, required this.dirSegments, required this.size});

  /// Local path (app folder) or SAF document URI (public folder).
  final String location;
  final String name;

  /// Folders relative to the GAMEBOX root, e.g. `[Games, NES]`.
  final List<String> dirSegments;
  final int size;

  bool get isDocument => location.startsWith('content://');

  ScannedEntry toEntry() => ScannedEntry(uri: location, name: name, dirSegments: dirSegments, size: size);
}

/// Where the GAMEBOX folder lives, and the operations that keep it
/// organised: create the layout, place downloaded files in their console
/// folder, register the suggested save folders, and check BIOS folders.
///
/// Two locations are supported:
/// * the app folder `Android/data/com.gamebox.console/files/GAMEBOX` (always
///   available, but deleted with the app and unreadable by path-only
///   emulators such as RetroArch on Android 11+);
/// * a public folder the user chose with the system folder picker (kept when
///   GAMEBOX is uninstalled, readable by emulators).
class LibraryLocationService {
  LibraryLocationService({
    required this._gateway,
    required this._settings,
    required this._appRoot,
    required this._saves,
    required this._installedEmulators,
  });

  final PlatformGateway _gateway;
  final SettingsRepository _settings;

  /// `<app folder>/GAMEBOX` on the primary volume.
  final Future<String> Function() _appRoot;
  final SaveService _saves;

  /// Ids of the emulator apps currently installed.
  final List<String> Function() _installedEmulators;

  String? get treeUri => _settings.state.value.libraryLocation;
  bool get isPublic => treeUri != null;

  /// Human-readable location for a relative folder.
  Future<String> describe([String rel = '']) async {
    final base = isPublic ? _treeLabel(treeUri!) : await _appRoot();
    return rel.isEmpty ? base : '$base/$rel';
  }

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
    if (tree == null) {
      final root = await _appRoot();
      final failed = <String>[];
      for (final f in folders) {
        try {
          await Directory('$root/$f').create(recursive: true);
        } catch (e) {
          failed.add('$f: $e');
        }
      }
      return failed;
    }
    final r = await _gateway.ensureTreeDirs(tree, folders);
    return [for (final f in (r['failed'] as List?) ?? const []) '$f'];
  }

  /// Uses the public folder [tree] (picked by the user) as the library
  /// location: creates the layout there, scans it for games, and registers
  /// the save folders of installed emulators.
  Future<List<String>> choose(String tree) async {
    await _settings.set(SettingsKeys.libraryLocation, tree);
    final folders = _settings.state.value.romFolders;
    if (!folders.contains(tree)) await _settings.setRomFolders([...folders, tree]);
    await _waitFor(() => treeUri == tree);
    final failed = await ensureStructure();
    await registerSaveFolders();
    return failed;
  }

  /// Back to the app folder. The public folder stays registered as a game
  /// folder; nothing is moved or deleted.
  Future<void> useAppStorage() async {
    await _settings.set(SettingsKeys.libraryLocation, '');
    await _waitFor(() => treeUri == null);
    await ensureStructure();
  }

  Future<void> _waitFor(bool Function() done) async {
    for (var i = 0; i < 50 && !done(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  /// Save Manager identity of an emulator's suggested save folder.
  /// Public folders use `<tree>#<relative path>`; the Save Manager scans
  /// only that part of the tree.
  Future<String> saveFolderUri(SaveLayout l) async =>
      isPublic ? '$treeUri#${l.root}' : '${await _appRoot()}/${l.root}';

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

  /// Moves the local file [localPath] into [relDir] (e.g. `Games/NES`).
  /// Never overwrites: a free name is chosen.
  Future<PlacedFile> place(String localPath, String relDir) async {
    final src = File(localPath);
    final name = src.uri.pathSegments.last;
    final size = await src.length();
    final dirs = relDir.split('/').where((s) => s.isNotEmpty).toList();
    final tree = treeUri;
    if (tree != null) {
      final uri = await _gateway.writeToTree(tree, relDir, name, localPath);
      await src.delete();
      return PlacedFile(location: uri, name: _nameOfDocument(uri, name), dirSegments: dirs, size: size);
    }
    final dir = Directory('${await _appRoot()}/$relDir');
    await dir.create(recursive: true);
    final dest = _freeFile(dir.path, name);
    await _move(src, dest);
    return PlacedFile(location: dest.path, name: dest.uri.pathSegments.last, dirSegments: dirs, size: size);
  }

  /// Moves every file under the local folder [localDir] into [relDir]
  /// (e.g. `Games/PS1/My Game`), keeping sub-folders; the local folder is
  /// removed afterwards.
  Future<List<PlacedFile>> placeFolder(String localDir, String relDir) async {
    final src = Directory(localDir);
    final files = [await for (final e in src.list(recursive: true, followLinks: false)) if (e is File) e];
    final placed = <PlacedFile>[];
    final tree = treeUri;
    if (tree == null) {
      final target = _freeDir('${await _appRoot()}/$relDir');
      await target.parent.create(recursive: true);
      try {
        await src.rename(target.path);
      } on FileSystemException {
        // Different volume: copy, then remove.
        for (final f in files) {
          final rel = f.path.substring(src.path.length + 1);
          final out = File('${target.path}/$rel');
          await out.parent.create(recursive: true);
          await f.copy(out.path);
        }
        await src.delete(recursive: true);
      }
      final base = target.path.substring((await _appRoot()).length + 1).split('/');
      await for (final e in target.list(recursive: true, followLinks: false)) {
        if (e is! File) continue;
        final rel = e.path.substring(target.path.length + 1).split('/');
        placed.add(PlacedFile(
          location: e.path,
          name: rel.last,
          dirSegments: [...base, ...rel.sublist(0, rel.length - 1)],
          size: await e.length(),
        ));
      }
      return placed;
    }
    // Public folder: a free folder name, then copy file by file.
    final relSegs = relDir.split('/').where((s) => s.isNotEmpty).toList();
    final parent = relSegs.sublist(0, relSegs.length - 1).join('/');
    final taken = {for (final n in await _gateway.listTreeNames(tree, parent)) n.toLowerCase()};
    var leaf = relSegs.last;
    for (var n = 2; taken.contains(leaf.toLowerCase()); n++) {
      leaf = '${relSegs.last} ($n)';
    }
    final base = [...relSegs.sublist(0, relSegs.length - 1), leaf];
    for (final f in files) {
      final rel = f.path.substring(src.path.length + 1).split('/');
      final dirs = [...base, ...rel.sublist(0, rel.length - 1)];
      final uri = await _gateway.writeToTree(tree, dirs.join('/'), rel.last, f.path);
      placed.add(PlacedFile(location: uri, name: _nameOfDocument(uri, rel.last), dirSegments: dirs, size: await f.length()));
    }
    await src.delete(recursive: true);
    return placed;
  }

  /// Deletes a placed document (used when a download entry is deleted).
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

  /// Which BIOS files are present in each `BIOS/<CONSOLE>` folder.
  Future<List<BiosStatus>> biosStatus() async {
    final out = <BiosStatus>[];
    final tree = treeUri;
    final root = tree == null ? await _appRoot() : null;
    for (final b in biosInfo) {
      List<String> names;
      try {
        if (tree != null) {
          names = await _gateway.listTreeNames(tree, b.dir);
        } else {
          final d = Directory('$root/${b.dir}');
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
