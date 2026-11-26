/// Finds games filed under the wrong console: a file whose header belongs to
/// another console (e.g. a PS2 DVD image in the PSP list). Only signatures
/// specific to one console count; anything unclear is not reported.
library;

import 'dart:typed_data';

import 'rom_header_validator.dart';

/// Bytes to read for [otherConsoleFromHeader] (disc volume descriptors sit at
/// 0x8000).
const consoleCheckBytes = 0x8800;

/// Console of a disc image from its volume descriptor: PSP UMD images say
/// "PSP GAME", PS2 DVDs "PLAYSTATION"; GameCube/Wii have disc magic.
String? discConsoleFromHeader(String ext, Uint8List b) {
  bool at(int off, List<int> sig) {
    if (b.length < off + sig.length) return false;
    for (var i = 0; i < sig.length; i++) {
      if (b[off + i] != sig[i]) return false;
    }
    return true;
  }

  if (ext == 'iso') {
    if (at(0x1C, [0xC2, 0x33, 0x9F, 0x3D])) return 'gamecube';
    if (at(0x18, [0x5D, 0x1C, 0x9E, 0xA3])) return 'wii';
    if (at(0x8001, 'CD001'.codeUnits)) {
      if (at(0x8008, 'PSP GAME'.codeUnits)) return 'psp';
      if (at(0x8008, 'PLAYSTATION'.codeUnits)) return 'ps2';
    }
  }
  if (ext == 'cso' && at(0, 'CISO'.codeUnits)) return 'psp';
  return null;
}

/// The console [bytes] (the start of a `.ext` file) really belong to, when it
/// is clearly not [consoleId]; null when it matches or is unclear.
String? otherConsoleFromHeader(String consoleId, String ext, Uint8List bytes) {
  if (bytes.isEmpty) return null;
  final disc = discConsoleFromHeader(ext, bytes);
  if (disc != null) {
    // PS1 discs carry the same "PLAYSTATION" identifier as PS2 DVDs.
    if (disc == 'ps2' && consoleId == 'ps1') return null;
    return disc == consoleId ? null : disc;
  }
  // Cartridges: the file fails this console's header check and passes
  // exactly one other console's check. Cartridge headers are specific
  // (iNES magic, Nintendo logo, "SEGA" string, checksums), so every console
  // is tried, whatever the file's extension (".bin" is used by several).
  if (validateRomHeader(consoleId, ext, bytes).status != HeaderStatus.invalid) return null;
  if (const {'chd', 'pbp'}.contains(ext)) return null;
  final family = _family(consoleId);
  final matches = <String>{
    for (final c in _cartridgeConsoles)
      if (!family.contains(c) && validateRomHeader(c, ext, bytes).status == HeaderStatus.valid) _family(c).first,
  };
  return matches.length == 1 ? matches.first : null;
}

const _cartridgeConsoles = ['nes', 'snes', 'sms', 'megadrive', 'gb', 'gbc', 'gba', 'n64', 'nds'];

/// Consoles that share games (a Game Boy game plays on a Game Boy Color).
Set<String> _family(String id) => const {'gb', 'gbc'}.contains(id) ? const {'gb', 'gbc'} : {id};
