/// Lightweight ROM header checks (file integrity verification).
///
/// Only well-documented, format-level signatures are checked. A file that
/// fails is reported as "invalid header", which usually means a corrupt,
/// truncated or mislabelled file. Formats without a reliable signature are
/// reported as "not checked" — never as valid.
library;

import 'dart:typed_data';

enum HeaderStatus { valid, invalid, notChecked }

class HeaderCheck {
  const HeaderCheck(this.status, this.detail);
  final HeaderStatus status;
  final String detail;
}

/// Bytes needed from the start of the file for [validateRomHeader].
const romHeaderBytes = 0x8000;

/// Nintendo logo bitmap present in every licensed Game Boy cartridge header
/// at 0x104–0x133 (checked against the first 16 bytes here only).
const _gbLogoStart = [0xCE, 0xED, 0x66, 0x66, 0xCC, 0x0D, 0x00, 0x0B, 0x03, 0x73, 0x00, 0x83, 0x00, 0x0C, 0x00, 0x0D];

HeaderCheck validateRomHeader(String consoleId, String extension, Uint8List b) {
  bool at(int offset, List<int> sig) {
    if (b.length < offset + sig.length) return false;
    for (var i = 0; i < sig.length; i++) {
      if (b[offset + i] != sig[i]) return false;
    }
    return true;
  }

  HeaderCheck ok(String d) => HeaderCheck(HeaderStatus.valid, d);
  HeaderCheck bad(String d) => HeaderCheck(HeaderStatus.invalid, d);
  const skip = HeaderCheck(HeaderStatus.notChecked, 'No reliable header signature for this format');

  if (b.isEmpty) return bad('File is empty');
  if (extension == 'chd') return at(0, 'MComprHD'.codeUnits) ? ok('CHD header') : bad('Missing CHD signature');
  if (extension == 'pbp') return at(0, [0x00, 0x50, 0x42, 0x50]) ? ok('PBP header') : bad('Missing PBP signature');

  switch (consoleId) {
    case 'nes':
      if (extension == 'fds') {
        return at(0, [0x46, 0x44, 0x53, 0x1A]) || at(1, [0x2A, 0x4E, 0x49, 0x4E, 0x54, 0x45, 0x4E, 0x44, 0x4F])
            ? ok('FDS disk image')
            : bad('Missing FDS signature');
      }
      if (extension == 'unf' || extension == 'unif') {
        return at(0, 'UNIF'.codeUnits) ? ok('UNIF header') : bad('Missing UNIF signature');
      }
      if (!at(0, [0x4E, 0x45, 0x53, 0x1A])) return bad('Missing iNES "NES\\x1A" signature');
      return ok((b.length > 7 && (b[7] & 0x0C) == 0x08) ? 'NES 2.0 header' : 'iNES header');

    case 'gb':
    case 'gbc':
      if (b.length < 0x150) return bad('File too small for a Game Boy header');
      if (!at(0x104, _gbLogoStart)) return bad('Nintendo logo not found in header');
      var sum = 0;
      for (var i = 0x134; i <= 0x14C; i++) {
        sum = (sum - b[i] - 1) & 0xFF;
      }
      return sum == b[0x14D]
          ? ok('Header checksum OK')
          : bad('Header checksum mismatch (0x${b[0x14D].toRadixString(16)} != 0x${sum.toRadixString(16)})');

    case 'gba':
      if (b.length < 0xC0) return bad('File too small for a GBA header');
      if (b[0xB2] != 0x96) return bad('Fixed header byte 0xB2 is not 0x96');
      var chk = 0;
      for (var i = 0xA0; i <= 0xBC; i++) {
        chk = (chk - b[i]) & 0xFF;
      }
      chk = (chk - 0x19) & 0xFF;
      return chk == b[0xBD] ? ok('Header complement check OK') : bad('Header complement check mismatch');

    case 'n64':
      if (at(0, [0x80, 0x37, 0x12, 0x40])) return ok('Big-endian (.z64) image');
      if (at(0, [0x37, 0x80, 0x40, 0x12])) return ok('Byte-swapped (.v64) image');
      if (at(0, [0x40, 0x12, 0x37, 0x80])) return ok('Little-endian (.n64) image');
      return bad('Unknown N64 byte order signature');

    case 'nds':
      if (b.length < 0x160) return bad('File too small for an NDS header');
      final crc = _crc16Modbus(b, 0, 0x15E);
      final stored = b[0x15E] | (b[0x15F] << 8);
      return crc == stored ? ok('Header CRC16 OK') : bad('Header CRC16 mismatch');

    case 'sms':
      for (final off in const [0x7FF0, 0x3FF0, 0x1FF0]) {
        if (at(off, 'TMR SEGA'.codeUnits)) return ok('"TMR SEGA" header at 0x${off.toRadixString(16)}');
      }
      // Some Japanese/early titles omit the header; not an error.
      return const HeaderCheck(HeaderStatus.notChecked, 'No "TMR SEGA" header (optional on some cartridges)');

    case 'megadrive':
      if (extension == 'smd') return skip; // interleaved format
      return at(0x100, 'SEGA'.codeUnits) || at(0x101, 'SEGA'.codeUnits)
          ? ok('"SEGA" system string at 0x100')
          : bad('"SEGA" system string not found at 0x100');

    case 'snes':
      // SNES headers have no fixed magic; check the checksum/complement pair
      // at the LoROM or HiROM location (copier header of 512 bytes allowed).
      for (final base in const [0x7FC0, 0xFFC0, 0x7FC0 + 0x200, 0xFFC0 + 0x200]) {
        if (b.length < base + 0x20) continue;
        final comp = b[base + 0x1C] | (b[base + 0x1D] << 8);
        final sum = b[base + 0x1E] | (b[base + 0x1F] << 8);
        if ((comp ^ sum) == 0xFFFF) return ok('Checksum/complement pair found');
      }
      return b.length < 0x10000
          ? const HeaderCheck(HeaderStatus.notChecked, 'Header area not read')
          : bad('No valid checksum/complement pair');

    case 'psp':
    case 'ps2':
    case 'gamecube':
    case 'wii':
      if (extension == 'iso' && b.length >= 0x8006 && at(0x8001, 'CD001'.codeUnits)) {
        return ok('ISO 9660 volume descriptor');
      }
      if (consoleId == 'gamecube' && extension == 'iso' && at(0x1C, [0xC2, 0x33, 0x9F, 0x3D])) {
        return ok('GameCube disc magic');
      }
      if (consoleId == 'wii' && extension == 'iso' && at(0x18, [0x5D, 0x1C, 0x9E, 0xA3])) {
        return ok('Wii disc magic');
      }
      if (extension == 'cso') return at(0, 'CISO'.codeUnits) ? ok('CISO header') : bad('Missing CISO signature');
      if (extension == 'rvz') return at(0, [0x52, 0x56, 0x5A, 0x01]) ? ok('RVZ header') : bad('Missing RVZ signature');
      if (extension == 'wbfs') return at(0, 'WBFS'.codeUnits) ? ok('WBFS header') : bad('Missing WBFS signature');
      return skip;
  }
  return skip;
}

int _crc16Modbus(Uint8List data, int start, int end) {
  var crc = 0xFFFF;
  for (var i = start; i < end; i++) {
    crc ^= data[i];
    for (var j = 0; j < 8; j++) {
      crc = (crc & 1) != 0 ? (crc >> 1) ^ 0xA001 : crc >> 1;
    }
  }
  return crc & 0xFFFF;
}
