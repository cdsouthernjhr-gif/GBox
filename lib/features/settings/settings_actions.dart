import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/database/app_database.dart';
import '../../core/database/db_maintenance.dart';
import '../../core/utilities/formatters.dart';
import '../../data/repositories/settings_repository.dart';
import '../../shared/widgets/tv_widgets.dart';

void _snack(BuildContext context, String m) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), duration: const Duration(seconds: 6)));

Future<String> _libraryBackupDir(BuildContext context) async => '${await servicesOf(context).gameboxRoot()}/Backups/library';

Future<void> backupLibraryNow(BuildContext context) async {
  final s = servicesOf(context);
  final dir = await _libraryBackupDir(context);
  await Directory(dir).create(recursive: true);
  final t = DateTime.now();
  final path = '$dir/gamebox_${t.millisecondsSinceEpoch}.sqlite';
  try {
    await s.db.backupTo(path);
    if (context.mounted) _snack(context, 'Library backed up: $path');
  } catch (e) {
    if (context.mounted) _snack(context, 'Backup failed: $e');
  }
}

Future<void> backupLibraryAction(BuildContext context) => backupLibraryNow(context);

Future<void> restoreLibraryAction(BuildContext context) async {
  final dir = Directory(await _libraryBackupDir(context));
  final files = await dir.exists()
      ? (await dir.list().where((e) => e is File && e.path.endsWith('.sqlite')).cast<File>().toList())
      : <File>[];
  // Copies GAMEBOX made itself before a database upgrade (next to the database).
  final dbDir = File(await AppDatabase.databaseFilePath()).parent;
  if (await dbDir.exists()) {
    files.addAll(await dbDir
        .list()
        .where((e) => e is File && RegExp(r'gamebox\.before-v\d+\.sqlite$').hasMatch(e.path))
        .cast<File>()
        .toList());
  }
  files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
  if (!context.mounted) return;
  if (files.isEmpty) {
    _snack(context, 'No library backups found in ${dir.path}');
    return;
  }
  final chosen = await showDialog<File>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Restore library backup'),
      content: SizedBox(
        width: 520,
        child: ListView(shrinkWrap: true, children: [
          const Text('The current library is kept as gamebox.before-restore.sqlite. Restart GAMEBOX to apply.',
              style: TextStyle(fontSize: 12, color: Colors.white60)),
          for (final (i, f) in files.indexed)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: TvFocusable(
                autofocus: i == 0,
                padding: const EdgeInsets.all(10),
                onSelect: () => Navigator.pop(c, f),
                child: Text('${formatDateTime(f.lastModifiedSync())} · ${formatBytes(f.lengthSync())}'
                    '${_upgradeLabel(f.path)}'),
              ),
            ),
        ]),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel'))],
    ),
  );
  if (chosen == null || !context.mounted) return;
  try {
    await stageRestore(chosen.path, await AppDatabase.databaseFilePath());
    if (context.mounted) _snack(context, 'Restore prepared. Restart GAMEBOX (or the box) to apply it.');
  } on FormatException catch (e) {
    if (context.mounted) _snack(context, e.message);
  }
}

/// " · before the upgrade to database v6" for copies made before upgrades.
String _upgradeLabel(String path) {
  final m = RegExp(r'gamebox\.before-v(\d+)\.sqlite$').firstMatch(path);
  return m == null ? '' : ' · before the upgrade to database v${m.group(1)}';
}

Future<void> chooseWallpaperAction(BuildContext context) async {
  final s = servicesOf(context);
  try {
    final uri = await s.gateway.pickImage();
    if (uri == null) return;
    final dir = await getApplicationSupportDirectory();
    final path = await s.gateway.importImage(
        uri, '${dir.path}/wallpaper_${DateTime.now().millisecondsSinceEpoch}.jpg', maxDim: 1920);
    if (path == null) {
      if (context.mounted) _snack(context, 'That file could not be read as an image.');
      return;
    }
    await s.settings.set(SettingsKeys.wallpaperImage, path);
  } on PlatformException catch (e) {
    if (context.mounted) _snack(context, 'Image picker unavailable: ${e.message}');
  }
}
