/// Where to get each emulator app: its Play Store listing and the
/// developer's own page. Only official sources; GAMEBOX never hosts or
/// downloads emulators itself (links open in the Play Store or the browser).
library;

class EmulatorLinks {
  const EmulatorLinks({this.playPackage, this.site, this.note});

  /// Package of the Play Store listing.
  final String? playPackage;

  /// Developer's download or project page.
  final String? site;
  final String? note;

  String? get playStoreApp => playPackage == null ? null : 'market://details?id=$playPackage';
  String? get playStoreWeb => playPackage == null ? null : 'https://play.google.com/store/apps/details?id=$playPackage';
}

const emulatorLinks = <String, EmulatorLinks>{
  'retroarch': EmulatorLinks(playPackage: 'com.retroarch', site: 'https://www.retroarch.com/?page=platforms'),
  'ppsspp': EmulatorLinks(playPackage: 'org.ppsspp.ppsspp', site: 'https://www.ppsspp.org/download/'),
  'duckstation': EmulatorLinks(playPackage: 'com.github.stenzek.duckstation', site: 'https://www.duckstation.org/'),
  'mupen64plus_fz': EmulatorLinks(
      playPackage: 'org.mupen64plusae.v3.fzurita', site: 'https://github.com/mupen64plus-ae/mupen64plus-ae'),
  'melonds': EmulatorLinks(playPackage: 'me.magnum.melonds', site: 'https://github.com/rafaelvcaetano/melonDS-android'),
  'drastic': EmulatorLinks(playPackage: 'com.dsemu.drastic', site: 'https://drastic-ds.com/', note: 'Paid app.'),
  'flycast': EmulatorLinks(playPackage: 'com.flycast.emulator', site: 'https://github.com/flyinghead/flycast'),
  'redream': EmulatorLinks(playPackage: 'io.recompiled.redream', site: 'https://redream.io/'),
  'dolphin': EmulatorLinks(playPackage: 'org.dolphinemu.dolphinemu', site: 'https://dolphin-emu.org/download/'),
  'aethersx2': EmulatorLinks(note: 'No longer distributed by its developer, so GAMEBOX links to no download.'),
};

/// Legal sources of free homebrew games, shown next to the web search.
class HomebrewSource {
  const HomebrewSource(this.name, this.url, this.description);
  final String name;
  final String url;
  final String description;
}

const homebrewSources = <HomebrewSource>[
  HomebrewSource('itch.io — homebrew', 'https://itch.io/games/tag-homebrew',
      'New games for old consoles by independent developers; many are free.'),
  HomebrewSource('Homebrew Hub', 'https://hh.gbdev.io/', 'Game Boy and Game Boy Color homebrew, playable and downloadable.'),
  HomebrewSource('PDRoms', 'https://pdroms.de/', 'Homebrew and public-domain games for many consoles.'),
];
