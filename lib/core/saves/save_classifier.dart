/// Classifies emulator save files and matches them to library games.
///
/// GAMEBOX keeps the three kinds strictly separate (spec Part 16):
/// * **state**  – emulator save states (snapshot of the emulator; only valid
///   for the same emulator/core and often the same version);
/// * **native** – the game's own save (battery RAM, EEPROM, flash);
/// * **memcard** – emulated memory cards shared by several games.
library;

import '../rom/title_normalizer.dart';

enum SaveKind { state, native, memcard }

extension SaveKindLabel on SaveKind {
  String get label => switch (this) {
        SaveKind.state => 'Save state',
        SaveKind.native => 'Game save',
        SaveKind.memcard => 'Memory card',
      };
}

class SaveFileInfo {
  const SaveFileInfo(this.kind, {this.slot});
  final SaveKind kind;

  /// Save-state slot, when the file name encodes one.
  final int? slot;
}

const _nativeExtensions = {'srm', 'sav', 'eep', 'fla', 'sra', 'dsv', 'rtc'};
const _memcardExtensions = {'mcd', 'mcr', 'mc', 'gci', 'ps2', 'mpk'};

/// All extensions worth listing when scanning a save folder.
const saveScanExtensions = {
  ..._nativeExtensions,
  ..._memcardExtensions,
  'state', 'state1', 'state2', 'state3', 'state4', 'state5', 'state6', 'state7', 'state8', 'state9',
  'ppst', 'auto',
};

/// Returns null for files that are not recognised save files.
SaveFileInfo? classifySave(String fileName) {
  final ext = extensionOf(fileName);
  if (_nativeExtensions.contains(ext)) return const SaveFileInfo(SaveKind.native);
  if (_memcardExtensions.contains(ext)) return const SaveFileInfo(SaveKind.memcard);
  final m = RegExp(r'^state(\d*)$').firstMatch(ext);
  if (m != null) return SaveFileInfo(SaveKind.state, slot: m.group(1)!.isEmpty ? 0 : int.parse(m.group(1)!));
  if (ext == 'auto' && fileName.toLowerCase().endsWith('.state.auto')) {
    return const SaveFileInfo(SaveKind.state, slot: -1); // RetroArch auto-save state
  }
  if (ext == 'ppst') {
    // PPSSPP: <GAMEID>_<version>_<slot>.ppst
    final slot = RegExp(r'_(\d+)\.ppst$', caseSensitive: false).firstMatch(fileName);
    return SaveFileInfo(SaveKind.state, slot: slot == null ? null : int.parse(slot.group(1)!));
  }
  return null;
}

/// The part of a save file name that identifies the game
/// (`Game (USA).state3` → `Game (USA)`, `Game.state.auto` → `Game`).
String saveBaseName(String fileName) {
  var n = fileName;
  if (n.toLowerCase().endsWith('.state.auto')) n = n.substring(0, n.length - '.state.auto'.length);
  return stripExtension(n);
}

/// Matches a save file to one of [candidates] (game id → names to compare:
/// title and ROM file names). Returns null when no unique match exists.
int? matchSaveToGame(String saveFileName, Map<int, List<String>> candidates) {
  final key = normalizeForMatch(saveBaseName(saveFileName));
  if (key.isEmpty) return null;
  int? found;
  for (final e in candidates.entries) {
    if (e.value.any((n) => normalizeForMatch(stripExtension(n)) == key || normalizeForMatch(n) == key)) {
      if (found != null && found != e.key) return null; // ambiguous
      found = e.key;
    }
  }
  return found;
}
