// On-device smoke test. Run on a real Android TV box / emulator with:
//   flutter test integration_test/device_smoke_test.dart -d <device-id>
// Status: PENDING until executed on physical hardware (see docs/TESTING_GUIDE.md).
import 'package:flutter_test/flutter_test.dart';
import 'package:gamebox/core/device/device_intelligence_service.dart';
import 'package:gamebox/core/services/platform_gateway.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('native hardware scan returns a usable profile', (tester) async {
    final gateway = MethodChannelGateway();
    final raw = await gateway.scanHardware();
    final p = DeviceIntelligenceService.profileFromNative(raw);
    expect(p.sdkInt, isNotNull);
    expect(p.supportedAbis, isNotEmpty);
    expect(p.totalRamBytes, greaterThan(0));
    expect(p.storageVolumes.where((v) => v.isPrimary), isNotEmpty);
  });

  testWidgets('launcher, storage and input channels respond', (tester) async {
    final gateway = MethodChannelGateway();
    expect(await gateway.isDefaultLauncher(), isA<bool>());
    expect(await gateway.storageVolumes(), isNotEmpty);
    expect(await gateway.listInputDevices(), isA<List<Map<String, dynamic>>>());
    expect((await gateway.connectivity()).transport, isNotEmpty);
  });
}
