import 'package:flutter_test/flutter_test.dart';
import 'package:gamebox/core/constants/console_catalog.dart';
import 'package:gamebox/core/constants/custom_console.dart';
import 'package:gamebox/core/rom/console_detector.dart';

void main() {
  tearDown(customConsoles.clear);

  const neo = CustomConsole(id: 'user_atari2600', name: 'Atari 2600', folder: 'atari2600', extensions: ['a26', 'zip']);

  test('typed values are checked before saving', () {
    expect(CustomConsole.folderFor('Neo Geo AES!'), 'neogeoaes');
    expect(CustomConsole.problem('Neo Geo', 'neogeo', ['zip'], const []), isNotNull, reason: 'now a built-in system');
    expect(CustomConsole.parseExtensions('.ZIP, neo;  7z zip'), ['zip', 'neo', '7z']);
    expect(CustomConsole.problem('Atari 2600', 'atari2600', ['a26'], const []), isNull);
    expect(CustomConsole.problem('', 'neogeo', ['zip'], const []), contains('name'));
    expect(CustomConsole.problem('X', 'Bad Folder', ['zip'], const []), contains('Folder'));
    expect(CustomConsole.problem('X', 'x', const [], const []), contains('file type'));
    expect(CustomConsole.problem('X', 'x', ['toolongext'], const []), contains('Not a file type'));
    expect(CustomConsole.problem('X', 'psx', ['zip'], const []), contains('already used'), reason: 'ROMs/psx is PS1');
    expect(CustomConsole.problem('X', 'gc', ['zip'], const []), contains('already used'), reason: 'GameCube alias');
    expect(CustomConsole.problem('PSP', 'pspx', ['zip'], const []), contains('already a system'));
    expect(CustomConsole.problem('Atari 2600', 'a2600', ['a26'], const [neo]), contains('already a system'));
  });

  test('saved as JSON with a user_ id; invalid entries dropped', () {
    final back = CustomConsole.decodeList(CustomConsole.encodeList([neo])).single;
    expect((back.id, back.name, back.folder), ('user_atari2600', 'Atari 2600', 'atari2600'));
    expect(back.extensions, ['a26', 'zip']);
    expect(CustomConsole.decodeList('[{"name":"x","folder":"BAD","extensions":["zip"]}]'), isEmpty);
    expect(CustomConsole.decodeList('nope'), isEmpty);
  });

  test('known by id; no hardware estimate category', () {
    customConsoles.add(neo.toDefinition());
    expect(consoleById('user_atari2600')?.name, 'Atari 2600');
    expect(consoleById('user_atari2600')?.category, ConsoleCategory.other);
    expect(allConsoles.last.id, 'user_atari2600');
  });

  test('scan: its folder and file types; never steals a known console\'s files', () {
    customConsoles
      ..add(neo.toDefinition())
      ..add(const CustomConsole(id: 'user_famiclone', name: 'Clone', folder: 'famiclone', extensions: ['nes'])
          .toDefinition());
    final d = ConsoleDetector();
    expect(d.detect('pitfall.zip', ['ROMs', 'atari2600'])?.consoleId, 'user_atari2600', reason: 'zip in its folder');
    expect(d.detect('pitfall.zip', ['Download']), isNull);
    expect(d.detect('pitfall.a26', ['Download'])?.consoleId, 'user_atari2600', reason: 'type only it uses');
    expect(d.detect('mario.nes', ['Download'])?.consoleId, 'nes', reason: 'still NES outside the folder');
    expect(d.detect('mario.nes', ['ROMs', 'famiclone'])?.consoleId, 'user_famiclone');
    expect(d.detect('mario.zip', ['ROMs', 'nes'])?.consoleId, 'nes');
  });
}
