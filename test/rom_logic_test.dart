import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:gamebox/core/rom/console_detector.dart';
import 'package:gamebox/core/rom/rom_header_validator.dart';
import 'package:gamebox/core/rom/scan_planner.dart';
import 'package:gamebox/core/rom/title_normalizer.dart';

// ---- Synthetic headers (built from public format documentation; no game
// data is used). ----

Uint8List nesRom() => Uint8List(0x4010)..setAll(0, [0x4E, 0x45, 0x53, 0x1A, 1, 1, 0, 0]);

Uint8List gbRom({bool corruptChecksum = false}) {
  final b = Uint8List(0x8000);
  b.setAll(0x104, [0xCE, 0xED, 0x66, 0x66, 0xCC, 0x0D, 0x00, 0x0B, 0x03, 0x73, 0x00, 0x83, 0x00, 0x0C, 0x00, 0x0D]);
  b.setAll(0x134, 'HOMEBREW'.codeUnits);
  var sum = 0;
  for (var i = 0x134; i <= 0x14C; i++) {
    sum = (sum - b[i] - 1) & 0xFF;
  }
  b[0x14D] = corruptChecksum ? (sum + 1) & 0xFF : sum;
  return b;
}

Uint8List gbaRom() {
  final b = Uint8List(0x200);
  b.setAll(0xA0, 'HOMEBREW'.codeUnits);
  b[0xB2] = 0x96;
  var chk = 0;
  for (var i = 0xA0; i <= 0xBC; i++) {
    chk = (chk - b[i]) & 0xFF;
  }
  b[0xBD] = (chk - 0x19) & 0xFF;
  return b;
}

Uint8List ndsRom() {
  final b = Uint8List(0x200);
  b.setAll(0, 'HOMEBREW'.codeUnits);
  var crc = 0xFFFF;
  for (var i = 0; i < 0x15E; i++) {
    crc ^= b[i];
    for (var j = 0; j < 8; j++) {
      crc = (crc & 1) != 0 ? (crc >> 1) ^ 0xA001 : crc >> 1;
    }
  }
  b[0x15E] = crc & 0xFF;
  b[0x15F] = crc >> 8;
  return b;
}

ScannedEntry e(String path, {int size = 1}) {
  final parts = path.split('/');
  return ScannedEntry(uri: 'test://$path', name: parts.last, dirSegments: parts.sublist(0, parts.length - 1), size: size);
}

void main() {
  group('title normalizer', () {
    test('strips tags and moves trailing article', () {
      final t = normalizeTitle('Legend of Zelda, The - A Link to the Past (USA) [!].sfc');
      expect(t.title, 'The Legend of Zelda - A Link to the Past');
      expect(t.sortTitle, 'legend of zelda - a link to the past');
      expect(t.regions, ['USA']);
      expect(t.tags, ['!']);
    });

    test('disc numbers and multi-region', () {
      final t = normalizeTitle('Some Game (Europe, Australia) (Disc 2).cue');
      expect(t.title, 'Some Game');
      expect(t.disc, 2);
      expect(t.regions, ['Europe', 'Australia']);
    });

    test('underscores and dotted names', () {
      expect(normalizeTitle('my_homebrew_game.nes').title, 'my homebrew game');
      expect(normalizeTitle('Super.Space.Demo.gba').title, 'Super Space Demo');
      expect(normalizeTitle('Dr. Demo (Rev 1).gb').title, 'Dr. Demo');
    });

    test('match key ignores case, punctuation and leading article', () {
      expect(normalizeForMatch('The Demo: Part 2 (USA)'), normalizeForMatch('demo - part 2'));
    });

    test('extensions', () {
      expect(extensionOf('a.B.SFC'), 'sfc');
      expect(extensionOf('noext'), '');
    });
  });

  group('console detector', () {
    final d = ConsoleDetector();

    test('unique extensions resolve without folders', () {
      expect(d.detect('game.sfc', const [])!.consoleId, 'snes');
      expect(d.detect('game.gba', const [])!.consoleId, 'gba');
      expect(d.detect('game.z64', const [])!.consoleId, 'n64');
    });

    test('shared extensions need a folder', () {
      expect(d.detect('game.iso', const []), isNull);
      expect(d.detect('game.iso', const ['ROMs', 'PSP'])!.consoleId, 'psp');
      expect(d.detect('game.iso', const ['roms', 'ps2'])!.consoleId, 'ps2');
      expect(d.detect('game.chd', const ['Sega Dreamcast'])!.consoleId, 'dreamcast');
      expect(d.detect('game.cue', const ['psx'])!.consoleId, 'ps1');
    });

    test('folder aliases from other frontends', () {
      expect(d.detect('game.iso', const ['GameCube'])!.consoleId, 'gamecube');
      expect(d.detect('game.iso', const ['ngc'])!.consoleId, 'gamecube');
    });

    test('folder naming a console that does not accept the extension is ignored', () {
      // .gba is never a SNES file even inside SNES/.
      expect(d.detect('game.gba', const ['SNES'])!.consoleId, 'gba');
    });

    test('closest folder wins', () {
      expect(d.detect('game.iso', const ['PS2', 'psp'])!.consoleId, 'psp');
    });

    test('archives only for cartridge systems, by folder', () {
      expect(d.detect('game.zip', const ['NES'])!.consoleId, 'nes');
      expect(d.detect('game.zip', const []), isNull);
      expect(d.detect('game.zip', const ['PSP']), isNull);
    });
  });

  group('header validator', () {
    test('NES', () {
      expect(validateRomHeader('nes', 'nes', nesRom()).status, HeaderStatus.valid);
      expect(validateRomHeader('nes', 'nes', Uint8List(16)).status, HeaderStatus.invalid);
    });

    test('Game Boy checksum', () {
      expect(validateRomHeader('gb', 'gb', gbRom()).status, HeaderStatus.valid);
      expect(validateRomHeader('gbc', 'gbc', gbRom(corruptChecksum: true)).status, HeaderStatus.invalid);
    });

    test('GBA complement', () {
      expect(validateRomHeader('gba', 'gba', gbaRom()).status, HeaderStatus.valid);
      final bad = gbaRom()..[0xBD] ^= 0xFF;
      expect(validateRomHeader('gba', 'gba', bad).status, HeaderStatus.invalid);
    });

    test('N64 byte orders', () {
      for (final sig in [
        [0x80, 0x37, 0x12, 0x40],
        [0x37, 0x80, 0x40, 0x12],
        [0x40, 0x12, 0x37, 0x80],
      ]) {
        expect(validateRomHeader('n64', 'z64', Uint8List(64)..setAll(0, sig)).status, HeaderStatus.valid);
      }
      expect(validateRomHeader('n64', 'z64', Uint8List(64)).status, HeaderStatus.invalid);
    });

    test('NDS CRC16', () {
      expect(validateRomHeader('nds', 'nds', ndsRom()).status, HeaderStatus.valid);
      expect(validateRomHeader('nds', 'nds', ndsRom()..[0x10] = 1).status, HeaderStatus.invalid);
    });

    test('CHD before console-specific checks', () {
      final chd = Uint8List(64)..setAll(0, 'MComprHD'.codeUnits);
      expect(validateRomHeader('psp', 'chd', chd).status, HeaderStatus.valid);
      expect(validateRomHeader('ps1', 'chd', Uint8List(64)).status, HeaderStatus.invalid);
    });

    test('formats without signature are never reported valid', () {
      expect(validateRomHeader('ps1', 'cue', Uint8List(64)..[0] = 0x46).status, HeaderStatus.notChecked);
    });

    test('empty file is invalid', () {
      expect(validateRomHeader('gba', 'gba', Uint8List(0)).status, HeaderStatus.invalid);
    });
  });

  group('scan planner', () {
    final d = ConsoleDetector();

    test('imports identifiable games and reports unresolved ones', () {
      final plan = planScan([
        e('NES/alpha.nes'),
        e('misc/disc.iso'),
        e('readme.txt'),
      ], d);
      expect(plan.games.map((g) => g.title.title), ['alpha']);
      expect(plan.unresolved.map((u) => u.name), ['disc.iso']);
    });

    test('track files are dropped when a cue exists in the folder', () {
      final plan = planScan([
        e('PS1/Game A/Game A.cue'),
        e('PS1/Game A/Game A (Track 1).bin'),
        e('PS1/Game A/Game A (Track 2).bin'),
        e('PS1/Lone/Lone.bin'),
      ], d);
      expect(plan.games.map((g) => g.primary.name), containsAll(['Game A.cue', 'Lone.bin']));
      expect(plan.games, hasLength(2));
      expect(plan.skippedCompanions, 2);
    });

    test('multi-disc sets become one game; m3u is primary', () {
      final plan = planScan([
        e('PS1/Epic (USA) (Disc 1).chd'),
        e('PS1/Epic (USA) (Disc 2).chd'),
        e('PS1/Epic (USA).m3u'),
      ], d);
      expect(plan.games, hasLength(1));
      final g = plan.games.single;
      expect(g.primary.name, 'Epic (USA).m3u');
      expect(g.files.map((f) => f.name), ['Epic (USA).m3u', 'Epic (USA) (Disc 1).chd', 'Epic (USA) (Disc 2).chd']);
    });

    test('multi-disc without m3u uses disc 1 as primary', () {
      final plan = planScan([e('PS1/Saga (Disc 2).cue'), e('PS1/Saga (Disc 1).cue')], d);
      expect(plan.games.single.primary.name, 'Saga (Disc 1).cue');
    });

    test('matching images become cover artwork', () {
      final plan = planScan([
        e('SNES/Demo World (USA).sfc'),
        e('Artwork/Covers/SNES/Demo World.png'),
        e('Artwork/Covers/GBA/Demo World.png'),
      ], d);
      expect(plan.games.single.cover!.displayPath, 'Artwork/Covers/SNES/Demo World.png');
    });
  });
}
