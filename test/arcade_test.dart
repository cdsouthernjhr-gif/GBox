import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gamebox/core/constants/console_catalog.dart';
import 'package:gamebox/core/database/app_database.dart';
import 'package:gamebox/core/rom/console_detector.dart';
import 'package:gamebox/core/rom/scan_planner.dart';
import 'package:gamebox/core/storage/gamebox_layout.dart';
import 'package:gamebox/features/emulator_manager/player_files.dart';
import 'package:gamebox/integrations/builtin/builtin_player_launcher.dart';
import 'package:gamebox/integrations/emulator_adapters/emulator_adapter.dart';

import 'online_core_test.dart' show zipOf;
import 'support/fakes.dart';

ScannedEntry entry(String path) {
  final parts = path.split('/');
  return ScannedEntry(uri: '/r/$path', name: parts.last, dirSegments: parts.sublist(0, parts.length - 1), size: 4096);
}

void main() {
  test('Neo Geo and arcade are built in with FinalBurn Neo; ROMs/neogeo and ROMs/arcade', () {
    expect(consoleById('neogeo')?.name, 'Neo Geo');
    expect(consoleById('arcade')?.name, 'Arcade');
    expect(builtInCores['neogeo'], 'fbneo');
    expect(builtInCores['arcade'], 'fbneo');
    expect(builtInSupportsDevice('arcade', ['armeabi-v7a']), isTrue);
    expect(builtInSupportsDevice('arcade', ['x86_64']), isTrue);
    expect(gamesDirFor('neogeo'), 'ROMs/neogeo');
    expect(gamesDirFor('arcade'), 'ROMs/arcade');
    // One BIOS folder for both (FinalBurn Neo's system folder).
    final dirs = {for (final b in biosInfo) if (b.consoleId == 'neogeo' || b.consoleId == 'arcade') b.dir};
    expect(dirs, {'GAMEBOX/BIOS/ARCADE'});
    expect(gameboxFolders().where((f) => f == 'GAMEBOX/BIOS/ARCADE'), hasLength(1));
  });

  test('scan: romset ZIPs count only in their folder; BIOS sets next to them are not games', () {
    final d = ConsoleDetector();
    expect(d.detect('mslug.zip', ['ROMs', 'neogeo'])?.consoleId, 'neogeo');
    expect(d.detect('sf2.zip', ['ROMs', 'arcade'])?.consoleId, 'arcade');
    expect(d.detect('sf2.zip', ['ROMs', 'fbneo'])?.consoleId, 'arcade', reason: 'common folder name');
    expect(d.detect('sf2.zip', ['Download']), isNull, reason: 'ZIPs elsewhere are not guessed');
    expect(d.detect('mario.zip', ['ROMs', 'nes'])?.consoleId, 'nes', reason: 'unchanged');

    final plan = planScan([
      entry('ROMs/neogeo/mslug.zip'),
      entry('ROMs/neogeo/neogeo.zip'),
      entry('ROMs/arcade/pgm.zip'),
      entry('ROMs/arcade/dino.zip'),
    ], d);
    expect(plan.games.map((g) => g.primary.name), unorderedEquals(['mslug.zip', 'dino.zip']));
  });

  group('built-in player', () {
    late Directory temp;
    setUp(() => temp = Directory.systemTemp.createTempSync('gamebox_arcade'));
    tearDown(() => temp.deleteSync(recursive: true));

    test('the romset is handed over as it is (never extracted), with the arcade BIOS folder', () async {
      final set = File('${temp.path}/ROMs/neogeo/mslug.zip')
        ..createSync(recursive: true)
        ..writeAsBytesSync(zipOf({'201-p1.p1': List.filled(64, 1)}));
      final files = PlayerFiles(
          gateway: FakeGateway(), cacheDir: () async => '${temp.path}/cache', dataBase: () async => '${temp.path}/base');
      final g = GameRow(
          id: 1, title: 'mslug', sortTitle: 'mslug', consoleId: 'neogeo', addedAt: DateTime(2026), playCount: 0, isMissing: false);
      final p = await files.prepare(g, [
        GameFileRow(id: 1, gameId: 1, uri: set.path, displayPath: 'mslug.zip', extension: 'zip', fileExists: true, isPrimary: true),
      ]);
      expect(p.problem, isNull);
      expect(p.romPath, set.path, reason: 'not extracted');
      expect(p.systemDir, '${temp.path}/base/GAMEBOX/BIOS/ARCADE');
      expect(Directory(p.systemDir!).existsSync(), isTrue);

      final plan = BuiltInPlayerLauncher().plan(
        LaunchTarget(consoleId: 'neogeo', originalUri: set.path, extension: 'zip', localPath: p.romPath, title: 'mslug'),
        LaunchEnvironment(installedPackage: 'com.gamebox.console', sdkInt: 34, systemDir: p.systemDir, savesDir: p.savesDir),
        const {},
      ) as LaunchReady;
      expect(plan.spec.extras['core'], 'fbneo');
      expect(plan.spec.extras['rom'], set.path);
    });
  });
}
