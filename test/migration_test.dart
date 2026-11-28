import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamebox/core/database/app_database.dart';
import 'package:gamebox/core/database/uuid.dart';

import 'generated_migrations/schema.dart';
import 'generated_migrations/schema_v1.dart' as v1;
import 'generated_migrations/schema_v5.dart' as v5;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  for (final from in [1, 2, 3, 4, 5]) {
    test('upgrade v$from → v6 produces exactly the v6 schema', () async {
      final connection = await verifier.startAt(from);
      final db = AppDatabase(connection);
      await verifier.migrateAndValidate(db, 6);
      await db.close();
    });
  }

  test('upgrade v1 → v6 keeps existing library data', () async {
    final schema = await verifier.schemaAt(1);
    final old = v1.DatabaseAtV1(schema.newConnection());
    await old.customStatement(
        "INSERT INTO consoles (id, name, manufacturer, category, folder_name, extensions, min_tier, "
        "recommended_tier) VALUES ('nes','NES','Nintendo','retro','NES','nes','entry','entry')");
    await old.customStatement(
        "INSERT INTO games (title, sort_title, console_id, added_at) VALUES ('Homebrew Test', 'homebrew test', 'nes', 0)");
    await old.customStatement(
        "INSERT INTO game_files (game_id, uri, display_path, extension) VALUES (1, '/x/test.nes', 'test.nes', 'nes')");
    await old.close();

    final db = AppDatabase(schema.newConnection());
    final games = await db.select(db.games).get();
    expect(games.single.title, 'Homebrew Test');
    expect(games.single.regions, isNull);
    final file = (await db.select(db.gameFiles).get()).single;
    expect(file.isPrimary, isTrue, reason: 'new column default applied to old rows');
    expect(file.rootUri, isNull);
    await db.close();
  });

  /// A v5 library: a game with a file, a favourite and two play sessions.
  Future<void> seedV5(QueryExecutor e) async {
    final old = v5.DatabaseAtV5(e);
    await old.customStatement(
        "INSERT INTO consoles (id, name, manufacturer, category, folder_name, extensions, min_tier, "
        "recommended_tier) VALUES ('nes','NES','Nintendo','retro','NES','nes','entry','entry')");
    for (final t in ['Alpha', 'Beta']) {
      await old.customStatement(
          "INSERT INTO games (title, sort_title, console_id, added_at) VALUES ('$t', '${t.toLowerCase()}', 'nes', 0)");
    }
    await old.customStatement(
        "INSERT INTO game_files (game_id, uri, display_path, extension) VALUES (1, '/x/a.nes', 'a.nes', 'nes')");
    await old.customStatement('INSERT INTO favorites (game_id, added_at) VALUES (1, 0)');
    await old.customStatement('INSERT INTO game_history (game_id, started_at) VALUES (1, 10), (2, 20)');
    await old.close();
  }

  test('upgrade v5 → v6: everything belongs to the default profile, every row gets a uuid', () async {
    final schema = await verifier.schemaAt(5);
    await seedV5(schema.newConnection());
    final db = AppDatabase(schema.newConnection());

    final profiles = await db.select(db.profiles).get();
    expect(profiles.single.id, defaultProfileId);
    expect(profiles.single.isDefault, isTrue);
    final favs = await db.select(db.favorites).get();
    expect(favs.single.gameId, 1);
    expect(favs.single.profileId, defaultProfileId);
    final history = await db.select(db.gameHistory).get();
    expect(history.map((h) => h.profileId).toSet(), {defaultProfileId});
    final uuids = [
      for (final g in await db.select(db.games).get()) g.uuid,
      for (final f in await db.select(db.gameFiles).get()) f.uuid,
      for (final h in history) h.uuid,
    ];
    expect(uuids, hasLength(5));
    expect(uuids.every((u) => u != null && isUuid(u)), isTrue, reason: '$uuids');
    expect(uuids.toSet(), hasLength(5), reason: 'unique');

    // Reads and writes use the active profile.
    final all = await db.watchAllGames().first;
    expect(all.firstWhere((g) => g.game.id == 1).isFavorite, isTrue);
    db.activeProfileId = 'someone-else';
    expect((await db.watchAllGames().first).any((g) => g.isFavorite), isFalse, reason: 'another profile');
    await db.close();
  });

  test('before upgrading, a consistent copy of the old database is kept', () async {
    final dir = Directory.systemTemp.createTempSync('gamebox_mig');
    addTearDown(() => dir.deleteSync(recursive: true));
    final schema = await verifier.schemaAt(5);
    await seedV5(schema.newConnection());
    final copy = '${dir.path}/${AppDatabase.preUpgradeBackupName(6)}';
    final db = AppDatabase(schema.newConnection(), preUpgradeBackup: (from, to) async {
      expect((from, to), (5, 6));
      return copy;
    });
    await db.select(db.games).get(); // opens and migrates
    await db.close();

    final backup = AppDatabase(NativeDatabase(File(copy)));
    // The copy is the v5 library (it is upgraded when opened like this).
    expect((await backup.select(backup.games).get()).map((g) => g.title), ['Alpha', 'Beta']);
    await backup.close();
  });

  test('a failing upgrade changes nothing: the old schema and data stay', () async {
    final dir = Directory.systemTemp.createTempSync('gamebox_mig');
    addTearDown(() => dir.deleteSync(recursive: true));
    final file = File('${dir.path}/gamebox.sqlite');
    // A v5 database file with a broken row: a favourite of a game that doesn't
    // exist (foreign keys were off). The upgrade's foreign key check fails.
    final raw = v5.DatabaseAtV5(NativeDatabase(file));
    await raw.customStatement(
        "INSERT INTO consoles (id, name, manufacturer, category, folder_name, extensions, min_tier, "
        "recommended_tier) VALUES ('nes','NES','Nintendo','retro','NES','nes','entry','entry')");
    await raw.customStatement("INSERT INTO games (title, sort_title, console_id, added_at) VALUES ('Alpha', 'alpha', 'nes', 0)");
    await raw.customStatement('INSERT INTO favorites (game_id, added_at) VALUES (99, 0)');
    await raw.customStatement('PRAGMA user_version = 5');
    await raw.close();

    final db = AppDatabase(NativeDatabase(file));
    await expectLater(db.select(db.games).get(),
        throwsA(predicate((e) => '$e'.contains('Upgrade check failed') && '$e'.contains('foreign key'))));
    await db.close();

    final after = v5.DatabaseAtV5(NativeDatabase(file));
    final version = await after.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.first, 5, reason: 'still v5');
    final tables = await after.customSelect("SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'profiles'").get();
    expect(tables, isEmpty, reason: 'rolled back');
    final favs = await after.customSelect('SELECT game_id FROM favorites').get();
    expect(favs.single.data['game_id'], 99, reason: 'data unchanged');
    await after.close();
  });
}
