import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamebox/core/database/app_database.dart';
import 'package:gamebox/core/device/device_intelligence_service.dart';
import 'package:gamebox/core/rom/rom_path_resolver.dart';
import 'package:gamebox/core/services/system_services.dart';
import 'package:gamebox/features/emulator_manager/launch_service.dart';
import 'package:gamebox/integrations/duckstation/duckstation_launcher.dart';
import 'package:gamebox/integrations/emulator_adapters/emulator_adapter.dart';
import 'package:gamebox/integrations/retroarch/retroarch_launcher.dart';

import 'support/fakes.dart';

const safNes = 'content://com.android.externalstorage.documents/tree/primary%3AROMs/document/'
    'primary%3AROMs%2FNES%2FSpace%20Quest.nes';
const usbPs1 = 'content://com.android.externalstorage.documents/tree/ABCD-1234%3AGames/document/'
    'ABCD-1234%3AGames%2FPSX%2FDemo.cue';
const downloadsUri = 'content://com.android.providers.downloads.documents/document/msf%3A42';
const appFolder = '/storage/emulated/0/Android/data/com.gamebox.console/files/GAMEBOX/Games/';

void main() {
  group('path resolver', () {
    test('primary and removable volumes', () {
      expect(resolveFilesystemPath(safNes), '/storage/emulated/0/ROMs/NES/Space Quest.nes');
      expect(resolveFilesystemPath(usbPs1), '/storage/ABCD-1234/Games/PSX/Demo.cue');
    });
    test('plain paths pass through; other providers have no path', () {
      expect(resolveFilesystemPath('/storage/x/y.gba'), '/storage/x/y.gba');
      expect(resolveFilesystemPath(downloadsUri), isNull);
    });
    test('path traversal in document ids is rejected', () {
      expect(
        resolveFilesystemPath('content://com.android.externalstorage.documents/document/primary%3A..%2Fdata'),
        isNull,
      );
    });
    test('app-private detection', () {
      expect(isAppPrivateExternalPath('${appFolder}NES/a.nes'), isTrue);
      expect(isAppPrivateExternalPath('/storage/emulated/0/ROMs/a.nes'), isFalse);
    });
  });

  group('RetroArch adapter', () {
    final ra = RetroArchLauncher();
    LaunchTarget t(String console, String? path) =>
        LaunchTarget(consoleId: console, originalUri: path ?? downloadsUri, extension: 'nes', filesystemPath: path);
    const env = LaunchEnvironment(installedPackage: 'com.retroarch.aarch64', sdkInt: 30);

    test('builds the documented RetroActivityFuture intent', () {
      final p = ra.plan(t('nes', '/storage/emulated/0/ROMs/NES/a.nes'), env, const {}) as LaunchReady;
      expect(p.spec.packageName, 'com.retroarch.aarch64');
      expect(p.spec.className, RetroArchLauncher.activity);
      expect(p.spec.extras['ROM'], '/storage/emulated/0/ROMs/NES/a.nes');
      expect(p.spec.extras['LIBRETRO'], '/data/data/com.retroarch.aarch64/cores/fceumm_libretro_android.so');
      expect(p.spec.extras['CONFIGFILE'], '/storage/emulated/0/Android/data/com.retroarch.aarch64/files/retroarch.cfg');
      expect(p.spec.flags, containsAll(['newTask', 'clearTask']));
    });

    test('core selection and fallback for unknown cores', () {
      final chosen = ra.plan(t('snes', '/r/a.sfc'), env, const {'core': 'snes9x2010'}) as LaunchReady;
      expect(chosen.spec.extras['LIBRETRO'], endsWith('/snes9x2010_libretro_android.so'));
      final bogus = ra.plan(t('snes', '/r/a.sfc'), env, const {'core': '../../evil'}) as LaunchReady;
      expect(bogus.spec.extras['LIBRETRO'], endsWith('/snes9x_libretro_android.so'));
    });

    test('blocked without a filesystem path', () {
      expect(ra.plan(t('gba', null), env, const {}), isA<LaunchBlocked>());
    });

    test('Android/data paths blocked on Android 11+, allowed before', () {
      final path = '${appFolder}NES/a.nes';
      expect(ra.plan(t('nes', path), env, const {}), isA<LaunchBlocked>());
      const env29 = LaunchEnvironment(installedPackage: 'com.retroarch', sdkInt: 29);
      expect(ra.plan(t('nes', path), env29, const {}), isA<LaunchReady>());
    });

    test('options expose cores per console; unsupported console blocked', () {
      expect(ra.options('ps1').single.values.keys, contains('pcsx_rearmed'));
      expect(ra.plan(t('ps2', '/r/a.iso'), env, const {}), isA<LaunchBlocked>());
    });
  });

  group('DuckStation adapter', () {
    final ds = DuckStationLauncher();
    const env = LaunchEnvironment(installedPackage: 'com.github.stenzek.duckstation', sdkInt: 33);

    test('prefers content URI and grants read access', () {
      const target = LaunchTarget(
          consoleId: 'ps1', originalUri: usbPs1, extension: 'cue',
          filesystemPath: '/storage/ABCD-1234/Games/PSX/Demo.cue', contentUri: usbPs1);
      final p = ds.plan(target, env, const {}) as LaunchReady;
      expect(p.spec.extras['bootPath'], usbPs1);
      expect(p.spec.grantReadUris, [usbPs1]);
      expect(p.spec.className, DuckStationLauncher.activity);
    });

    test('falls back to path; rejects other consoles', () {
      const target = LaunchTarget(consoleId: 'ps1', originalUri: '/r/a.chd', extension: 'chd', filesystemPath: '/r/a.chd');
      final p = ds.plan(target, env, const {}) as LaunchReady;
      expect(p.spec.extras['bootPath'], '/r/a.chd');
      expect(p.spec.grantReadUris, isEmpty);
      const nes = LaunchTarget(consoleId: 'nes', originalUri: '/r/a.nes', extension: 'nes', filesystemPath: '/r/a.nes');
      expect(ds.plan(nes, env, const {}), isA<LaunchBlocked>());
    });
  });

  group('launch service', () {
    late AppDatabase db;
    late FakeGateway gateway;
    late LaunchService launcher;
    late DeviceIntelligenceService device;
    var cacheCleared = 0;

    setUp(() async {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      db = AppDatabase(NativeDatabase.memory());
      gateway = FakeGateway(scan: syntheticNativeScan()..['sdkInt'] = 30);
      gateway.installed.clear();
      gateway.fileProviderBase = appFolder;
      device = DeviceIntelligenceService(gateway, db);
      await device.scan();
      cacheCleared = 0;
      launcher = LaunchService(
        gateway: gateway,
        db: db,
        emulators: EmulatorDetectionService(gateway, db),
        device: device,
        beforeLaunch: () => cacheCleared++,
      );
    });
    tearDown(() => db.close());

    Future<int> addGame(String console, String uri, {bool exists = true}) => db.insertGameWithFiles(
          GamesCompanion.insert(title: 'G', sortTitle: 'g', consoleId: console, addedAt: DateTime(2026)),
          [
            GameFilesCompanion.insert(
                gameId: 0, uri: uri, displayPath: uri.split('/').last, extension: uri.split('.').last,
                fileExists: Value(exists)),
          ],
        );

    test('no compatible emulator installed → clear message, nothing launched', () async {
      final id = await addGame('nes', safNes);
      final o = await launcher.play(id);
      expect(o.ok, isFalse);
      expect(o.reasons.single, contains('RetroArch'));
      expect(gateway.launchedSpecs, isEmpty);
    });

    test('launches RetroArch, records history, closes session on return', () async {
      gateway.installed['com.retroarch.aarch64'] = '1.20.0';
      final id = await addGame('nes', safNes);

      final o = await launcher.play(id);
      expect(o.ok, isTrue, reason: o.reasons.join());
      expect(o.emulatorName, 'RetroArch');
      expect(cacheCleared, 1);
      final spec = gateway.launchedSpecs.single;
      expect((spec['extras'] as Map)['ROM'], '/storage/emulated/0/ROMs/NES/Space Quest.nes');

      final game = await db.gameById(id);
      expect(game.playCount, 1);
      expect(game.lastPlayedAt, isNotNull);
      expect(await db.watchRecentlyPlayed().first, hasLength(1));

      await launcher.onReturned();
      final h = (await db.historyForGame(id)).single;
      expect(h.endedAt, isNotNull);
      expect(h.exitStatus, 'returned');
      expect(h.emulatorId, 'retroarch');
    });

    test('missing file is not launched', () async {
      gateway.installed['com.retroarch'] = '1.20.0';
      final id = await addGame('gba', '/storage/emulated/0/ROMs/a.gba', exists: false);
      final o = await launcher.play(id);
      expect(o.ok, isFalse);
      expect(o.reasons.single, contains('missing'));
      expect(gateway.launchedSpecs, isEmpty);
    });

    test('remembered default emulator and core are reused', () async {
      gateway.installed['com.retroarch'] = '1.20.0';
      gateway.installed['com.github.stenzek.duckstation'] = '0.1';
      final id = await addGame('ps1', '/storage/emulated/0/ROMs/PSX/demo.chd');

      await launcher.play(id, emulatorId: 'retroarch', options: {'core': 'swanstation'}, remember: true);
      await launcher.play(id);
      final last = gateway.launchedSpecs.last;
      expect(last['package'], 'com.retroarch');
      expect((last['extras'] as Map)['LIBRETRO'], endsWith('swanstation_libretro_android.so'));
    });

    test('GAMEBOX folder on Android 11+: RetroArch blocked, DuckStation gets a FileProvider URI', () async {
      gateway.installed['com.retroarch'] = '1.20.0';
      gateway.installed['com.github.stenzek.duckstation'] = '0.1';
      final id = await addGame('ps1', '${appFolder}PS1/demo.chd');

      final ra = await launcher.play(id, emulatorId: 'retroarch');
      expect(ra.ok, isFalse);
      expect(ra.reasons.single, contains('Android/data'));

      final ds = await launcher.play(id, emulatorId: 'duckstation');
      expect(ds.ok, isTrue, reason: ds.reasons.join());
      final spec = gateway.launchedSpecs.single;
      expect((spec['extras'] as Map)['bootPath'], 'content://com.gamebox.console.files/gamebox/PS1/demo.chd');
      expect(spec['grantReadUris'], ['content://com.gamebox.console.files/gamebox/PS1/demo.chd']);
    });

    test('native launch failure is reported and not recorded as played', () async {
      gateway.installed['com.retroarch'] = '1.20.0';
      gateway.nextLaunchResult = {'ok': false, 'code': 'not_found', 'error': 'activity not found'};
      final id = await addGame('snes', safNes.replaceAll('.nes', '.sfc'));
      final o = await launcher.play(id);
      expect(o.ok, isFalse);
      expect(o.reasons.single, contains('activity not found'));
      expect((await db.gameById(id)).playCount, 0);
      expect(await db.historyForGame(id), isEmpty);
    });
  });
}
