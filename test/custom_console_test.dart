import 'package:flutter_test/flutter_test.dart';
import 'package:gamebox/core/constants/console_catalog.dart';
import 'package:gamebox/core/constants/custom_console.dart';
import 'package:gamebox/core/rom/console_detector.dart';

void main() {
  tearDown(customConsoles.clear);

  const neo = CustomConsole(id: 'user_neogeo', name: 'Neo Geo', folder: 'neogeo', extensions: ['zip', 'neo']);

  test('typed values are checked before saving', () {
    expect(CustomConsole.folderFor('Neo Geo AES!'), 'neogeoaes');
    expect(CustomConsole.parseExtensions('.ZIP, neo;  7z zip'), ['zip', 'neo', '7z']);
    expect(CustomConsole.problem('Neo Geo', 'neogeo', ['zip'], const []), isNull);
    expect(CustomConsole.problem('', 'neogeo', ['zip'], const []), contains('name'));
    expect(CustomConsole.problem('X', 'Bad Folder', ['zip'], const []), contains('Folder'));
    expect(CustomConsole.problem('X', 'x', const [], const []), contains('file type'));
    expect(CustomConsole.problem('X', 'x', ['toolongext'], const []), contains('Not a file type'));
    expect(CustomConsole.problem('X', 'psx', ['zip'], const []), contains('already used'), reason: 'ROMs/psx is PS1');
    expect(CustomConsole.problem('X', 'gc', ['zip'], const []), contains('already used'), reason: 'GameCube alias');
    expect(CustomConsole.problem('PSP', 'pspx', ['zip'], const []), contains('already a system'));
    expect(CustomConsole.problem('Neo Geo', 'neo2', ['zip'], const [neo]), contains('already a system'));
  });

  test('saved as JSON with a user_ id; invalid entries dropped', () {
    final back = CustomConsole.decodeList(CustomConsole.encodeList([neo])).single;
    expect((back.id, back.name, back.folder), ('user_neogeo', 'Neo Geo', 'neogeo'));
    expect(back.extensions, ['zip', 'neo']);
    expect(CustomConsole.decodeList('[{"name":"x","folder":"BAD","extensions":["zip"]}]'), isEmpty);
    expect(CustomConsole.decodeList('nope'), isEmpty);
  });

  test('known by id; no hardware estimate category', () {
    customConsoles.add(neo.toDefinition());
    expect(consoleById('user_neogeo')?.name, 'Neo Geo');
    expect(consoleById('user_neogeo')?.category, ConsoleCategory.other);
    expect(allConsoles.last.id, 'user_neogeo');
  });

  test('scan: its folder and file types; never steals a known console\'s files', () {
    customConsoles
      ..add(neo.toDefinition())
      ..add(const CustomConsole(id: 'user_famiclone', name: 'Clone', folder: 'famiclone', extensions: ['nes'])
          .toDefinition());
    final d = ConsoleDetector();
    expect(d.detect('kof98.zip', ['ROMs', 'neogeo'])?.consoleId, 'user_neogeo', reason: 'zip in its folder');
    expect(d.detect('kof98.zip', ['Download']), isNull);
    expect(d.detect('game.neo', ['Download'])?.consoleId, 'user_neogeo', reason: 'type only it uses');
    expect(d.detect('mario.nes', ['Download'])?.consoleId, 'nes', reason: 'still NES outside the folder');
    expect(d.detect('mario.nes', ['ROMs', 'famiclone'])?.consoleId, 'user_famiclone');
    expect(d.detect('mario.zip', ['ROMs', 'nes'])?.consoleId, 'nes');
  });
}
