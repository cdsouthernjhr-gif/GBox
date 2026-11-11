import 'package:drift/drift.dart' hide isNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamebox/core/database/app_database.dart';

import 'generated_migrations/schema.dart';
import 'generated_migrations/schema_v1.dart' as v1;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  for (final from in [1, 2]) {
    test('upgrade v$from → v3 produces exactly the v3 schema', () async {
      final connection = await verifier.startAt(from);
      final db = AppDatabase(connection);
      await verifier.migrateAndValidate(db, 3);
      await db.close();
    });
  }

  test('upgrade v1 → v3 keeps existing library data', () async {
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
}
