import 'package:flutter_test/flutter_test.dart';
import 'package:gamebox/integrations/emulator_adapters/custom_emulator.dart';
import 'package:gamebox/integrations/emulator_adapters/emulator_adapter.dart';
import 'package:gamebox/integrations/emulator_adapters/launcher_registry.dart';

void main() {
  tearDown(() => setCustomEmulators(const []));

  const env = LaunchEnvironment(installedPackage: 'org.example.emu', sdkInt: 34);
  const target = LaunchTarget(
    consoleId: 'saturn',
    originalUri: '/s/ROMs/saturn/Race.cue',
    extension: 'cue',
    filesystemPath: '/storage/emulated/0/ROMs/saturn/Race.cue',
    contentUri: 'content://com.gamebox.console.files/roms/saturn/Race.cue',
    title: 'Race',
  );

  test('saved as JSON; invalid entries are dropped', () {
    const e = CustomEmulator(
        packageName: 'org.example.emu', name: 'My Saturn', consoleIds: {'saturn', 'ps1'}, method: CustomLaunchMethod.openFile);
    final back = CustomEmulator.decodeList(CustomEmulator.encodeList([e])).single;
    expect(back.packageName, 'org.example.emu');
    expect(back.consoleIds, {'saturn', 'ps1'});
    expect(back.id, 'custom:org.example.emu');
    expect(
        CustomEmulator.decodeList('[{"package":"not a package","name":"x","consoles":["nes"]},'
            '{"package":"a.b","name":"x","consoles":["unknown"]},'
            '{"package":"a.b","name":"x","consoles":["nes"],"method":"pathExtra"},'
            '{"package":"a.b","name":" Ok ","consoles":["nes"]}]'),
        [isA<CustomEmulator>().having((e) => e.name, 'name', 'Ok')]);
    expect(CustomEmulator.decodeList('garbage'), isEmpty);
  });

  test('open the game file: VIEW intent with the content URI, read access granted', () {
    final l = CustomLauncher(const CustomEmulator(packageName: 'org.example.emu', name: 'Emu', consoleIds: {'saturn'}));
    expect(l.emulator.name, 'Emu');
    final p = l.plan(target, env, const {}) as LaunchReady;
    expect(p.spec.packageName, 'org.example.emu');
    expect(p.spec.action, 'android.intent.action.VIEW');
    expect(p.spec.data, target.contentUri);
    expect(p.spec.grantReadUris, [target.contentUri]);
    expect(l.plan(const LaunchTarget(consoleId: 'nes', originalUri: 'x', extension: 'nes'), env, const {}),
        isA<LaunchBlocked>());
  });

  test('path extra and app only', () {
    final path = CustomLauncher(const CustomEmulator(
        packageName: 'org.example.emu',
        name: 'Emu',
        consoleIds: {'saturn'},
        method: CustomLaunchMethod.pathExtra,
        extraKey: 'ROM_PATH'));
    expect((path.plan(target, env, const {}) as LaunchReady).spec.extras, {'ROM_PATH': target.filesystemPath});
    final app = CustomLauncher(const CustomEmulator(
        packageName: 'org.example.emu', name: 'Emu', consoleIds: {'saturn'}, method: CustomLaunchMethod.appOnly));
    final p = app.plan(target, env, const {}) as LaunchReady;
    expect(p.spec.action, 'android.intent.action.MAIN');
    expect(p.spec.data, isNull);
    expect(p.notes.single, contains('Race'));
  });

  test('listed after the emulators GAMEBOX knows', () {
    setCustomEmulators(const [CustomEmulator(packageName: 'org.example.emu', name: 'Emu', consoleIds: {'nes'})]);
    final list = launchersForConsole('nes');
    expect(list.first.emulatorId, 'gamebox');
    expect(list.last.emulatorId, 'custom:org.example.emu');
    expect(launcherFor('custom:org.example.emu'), isA<CustomLauncher>());
    setCustomEmulators(const []);
    expect(launcherFor('custom:org.example.emu'), isNull);
  });
}
