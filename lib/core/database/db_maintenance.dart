/// Library database backup and restore.
///
/// Backup: `VACUUM INTO` produces a consistent copy of the live database.
/// Restore: the chosen backup is validated and *staged* next to the live
/// file; it is swapped in at the next app start, before the database is
/// opened (a live SQLite file must not be replaced while open). The previous
/// database is kept as `gamebox.before-restore.sqlite`.
library;

import 'dart:io';

const restorePendingName = 'gamebox.restore.sqlite';
const beforeRestoreName = 'gamebox.before-restore.sqlite';

bool isSqliteFile(File f) {
  try {
    final raf = f.openSync();
    final header = raf.readSync(16);
    raf.closeSync();
    return String.fromCharCodes(header) == 'SQLite format 3\u0000';
  } catch (_) {
    return false;
  }
}

String _dir(String path) => File(path).parent.path;

/// Validates [backupPath] and stages it for the next start.
Future<void> stageRestore(String backupPath, String databasePath) async {
  final src = File(backupPath);
  if (!await src.exists() || !isSqliteFile(src)) {
    throw const FormatException('Not a GAMEBOX library backup');
  }
  await src.copy('${_dir(databasePath)}/$restorePendingName');
}

/// Applies a staged restore. Call before opening the database.
/// Returns a message for the log/UI, or null when nothing was pending.
Future<String?> applyPendingRestore(String databasePath) async {
  final pending = File('${_dir(databasePath)}/$restorePendingName');
  if (!await pending.exists()) return null;
  if (!isSqliteFile(pending)) {
    await pending.delete();
    return 'Staged library restore was not a valid database and was ignored.';
  }
  final current = File(databasePath);
  if (await current.exists()) {
    final keep = File('${_dir(databasePath)}/$beforeRestoreName');
    if (await keep.exists()) await keep.delete();
    await current.rename(keep.path);
  }
  for (final suffix in ['-wal', '-shm', '-journal']) {
    final f = File('$databasePath$suffix');
    if (await f.exists()) await f.delete();
  }
  await pending.rename(databasePath);
  return 'Library restored from backup.';
}
