import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:gamebox/core/rom/console_mismatch.dart';
import 'package:gamebox/data/repositories/settings_repository.dart';
import 'package:gamebox/features/game_scraper/cover_art_service.dart';

import 'library_location_test.dart' show pspIso;
import 'rom_logic_test.dart' show gbaRom, nesRom;

Uint8List ps2Iso() => Uint8List(0x9000)
  ..setAll(0x8001, 'CD001'.codeUnits)
  ..setAll(0x8008, 'PLAYSTATION'.codeUnits);

void main() {
  group('game filed under the wrong console', () {
    test('disc images: the volume descriptor tells PSP from PS2', () {
      expect(otherConsoleFromHeader('psp', 'iso', ps2Iso()), 'ps2');
      expect(otherConsoleFromHeader('psp', 'iso', pspIso()), isNull);
      expect(otherConsoleFromHeader('ps2', 'iso', pspIso()), 'psp');
      // PS1 discs carry the same "PLAYSTATION" identifier.
      expect(otherConsoleFromHeader('ps1', 'iso', ps2Iso()), isNull);
      expect(otherConsoleFromHeader('psp', 'iso', Uint8List(0x9000)), isNull, reason: 'unclear');
    });

    test('cartridges: only a header specific to one other console counts', () {
      expect(otherConsoleFromHeader('megadrive', 'bin', gbaRom()), 'gba');
      expect(otherConsoleFromHeader('gba', 'bin', gbaRom()), isNull);
      expect(otherConsoleFromHeader('nes', 'nes', nesRom()), isNull);
      // Unknown content: never reported.
      expect(otherConsoleFromHeader('megadrive', 'bin', Uint8List(0x400)), isNull);
      expect(otherConsoleFromHeader('nes', 'nes', Uint8List(0)), isNull);
    });
  });

  group('cover art', () {
    test('names follow libretro-thumbnails (file name first, then title with regions)', () {
      final names = coverNameCandidates(title: 'Crash Bandicoot', fileStem: 'Crash Bandicoot (USA) [!]', regions: 'USA');
      expect(names.first, 'Crash Bandicoot (USA) [!]');
      expect(names[1], 'Crash Bandicoot (USA)');
      expect(names, containsAll(['Crash Bandicoot (Europe)', 'Crash Bandicoot (World)', 'Crash Bandicoot']));
      expect(names.toSet().length, names.length, reason: 'no duplicates');
      expect(coverNameCandidates(title: 'FF7', fileStem: 'Final Fantasy VII (USA) (Disc 1)'),
          contains('Final Fantasy VII (USA)'));
      expect(libretroThumbnailName('Ratchet & Clank: Going Commando?'), 'Ratchet _ Clank_ Going Commando_');
    });

    test('URLs: the libretro server, then the same collection on GitHub', () {
      final urls = coverUrls('ps1', 'Crash Bandicoot (USA)');
      expect(urls.map((u) => u.toString()), [
        'https://thumbnails.libretro.com/Sony%20-%20PlayStation/Named_Boxarts/Crash%20Bandicoot%20(USA).png',
        'https://raw.githubusercontent.com/libretro-thumbnails/Sony_-_PlayStation/master/Named_Boxarts/Crash%20Bandicoot%20(USA).png',
      ]);
      expect(coverUrls('unknown', 'x'), isEmpty);
      expect(CoverArtService.supports('snes'), isTrue);
    });
  });

  test('built-in player settings per emulator', () {
    final st = SettingsState.fromMap({
      SettingsKeys.playerTouch: 'off',
      SettingsKeys.playerCore('snes9x', 'shader'): 'crt',
      SettingsKeys.playerCore('pcsx_rearmed', 'touch'): 'on',
      SettingsKeys.playerCore('fceumm', 'touch'): '', // "same as general"
    });
    expect(st.shaderFor('snes9x'), PlayerShader.crt);
    expect(st.shaderFor('snes9x').wire, 'crt');
    expect(st.shaderFor('fceumm'), PlayerShader.standard);
    expect(PlayerShader.standard.wire, 'default');
    expect(st.touchFor('pcsx_rearmed'), PlayerTouch.on);
    expect(st.touchFor('fceumm'), PlayerTouch.off, reason: 'falls back to the general setting');
    expect(st.hasOwnTouch('fceumm'), isFalse);
    expect(st.hasOwnTouch('pcsx_rearmed'), isTrue);
  });
}
