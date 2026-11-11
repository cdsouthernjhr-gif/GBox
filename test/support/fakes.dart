import 'dart:async';

import 'package:flutter/services.dart';
import 'package:gamebox/core/services/platform_gateway.dart';

/// Sample `/proc/cpuinfo` captured in the format used by ARM64 kernels.
/// Used only to exercise the parser – not evidence about any real device.
const sampleArm64CpuInfo = '''
processor\t: 0
BogoMIPS\t: 48.00
Features\t: fp asimd evtstrm aes pmull sha1 sha2 crc32 cpuid
CPU implementer\t: 0x41
CPU architecture: 8
CPU variant\t: 0x0
CPU part\t: 0xd03
CPU revision\t: 4

processor\t: 1
Features\t: fp asimd evtstrm aes pmull sha1 sha2 crc32 cpuid
CPU implementer\t: 0x41
CPU part\t: 0xd03

processor\t: 2
Features\t: fp asimd evtstrm aes pmull sha1 sha2 crc32 cpuid
CPU implementer\t: 0x41
CPU part\t: 0xd09

processor\t: 3
Features\t: fp asimd evtstrm aes pmull sha1 sha2 crc32 cpuid
CPU implementer\t: 0x41
CPU part\t: 0xd09

Hardware\t: Amlogic
''';

/// Old ARMv7 kernel format where "Processor" is the model name.
const sampleArmv7CpuInfo = '''
Processor\t: ARMv7 Processor rev 4 (v7l)
processor\t: 0
BogoMIPS\t: 24.00
processor\t: 1
BogoMIPS\t: 24.00
Features\t: half thumb fastmult vfp edsp neon vfpv3 tls vfpv4 idiva idivt vfpd32 lpae evtstrm aes pmull sha1 sha2 crc32
CPU implementer\t: 0x41
CPU architecture: 7
CPU variant\t: 0x0
CPU part\t: 0xd03
CPU revision\t: 4
Hardware\t: sun50iw9
''';

/// Synthetic native scan map shaped like the Kotlin HardwareScanner output.
Map<String, dynamic> syntheticNativeScan({
  List<String> abis = const ['arm64-v8a', 'armeabi-v7a', 'armeabi'],
  List<String> abis64 = const ['arm64-v8a'],
  String? renderer = 'Mali-G52',
  String? glEs = '3.2',
  int? totalRam = 4 * 1024 * 1024 * 1024,
  String? cpuInfo = sampleArm64CpuInfo,
}) =>
    {
      'manufacturer': 'TestVendor',
      'brand': 'test',
      'model': 'Synthetic Box',
      'device': 'synthetic',
      'product': 'synthetic',
      'hardware': 'unknown',
      'androidVersion': '9',
      'sdkInt': 28,
      'buildId': 'TEST.1',
      'buildFingerprint': 'test/synthetic/box:9/TEST.1/1:user/release-keys',
      'supportedAbis': abis,
      'supported32BitAbis': const ['armeabi-v7a', 'armeabi'],
      'supported64BitAbis': abis64,
      'cpuInfoRaw': cpuInfo,
      'cpuCores': 4,
      'cpuMaxFreqKhz': 1800000,
      'totalRamBytes': totalRam,
      'availableRamBytes': totalRam == null ? null : totalRam ~/ 2,
      'lowMemory': false,
      'isLowRamDevice': false,
      'glEsVersion': glEs,
      'glVendor': 'ARM',
      'glRenderer': renderer,
      'glVersion': 'OpenGL ES 3.2',
      'vulkanSupported': true,
      'vulkanApiVersion': '1.1.0',
      'displayWidth': 1920,
      'displayHeight': 1080,
      'refreshRate': 60.0,
      'densityDpi': 320,
      'isTelevision': true,
      'storageVolumes': [
        {
          'id': 'primary',
          'description': 'Internal shared storage',
          'isPrimary': true,
          'isRemovable': false,
          'isEmulated': true,
          'state': 'mounted',
          'totalBytes': 16000000000,
          'availableBytes': 8000000000,
          'kind': 'internal',
        },
      ],
      'inputDevices': [
        {
          'id': 5,
          'name': 'Test Gamepad',
          'descriptor': 'abc123',
          'isExternal': true,
          'classes': ['gamepad', 'joystick', 'dpad'],
          'vendorId': 0x045e,
          'productId': 0x028e,
          'hasVibrator': false,
          'axes': ['X', 'Y'],
          'buttons': ['BUTTON_A', 'BUTTON_B'],
          'controllerNumber': 1,
        },
      ],
    };

class FakeGateway implements PlatformGateway {
  FakeGateway({Map<String, dynamic>? scan}) : scan = scan ?? syntheticNativeScan();

  Map<String, dynamic> scan;
  int scanCount = 0;
  final launched = <String>[];
  final inputEvents = StreamController<Map<String, dynamic>>.broadcast();
  final raw = StreamController<RawInputEvent>.broadcast();
  final installed = <String, String?>{'org.ppsspp.ppsspp': '1.17.1'};

  @override
  Future<Map<String, dynamic>> scanHardware() async {
    scanCount++;
    return scan;
  }

  @override
  Future<Map<String, dynamic>> memoryInfo() async => {'totalRamBytes': scan['totalRamBytes']};

  @override
  Future<ConnectivityStatus> connectivity() async => ConnectivityStatus.offline;

  @override
  Stream<ConnectivityStatus> connectivityChanges() => const Stream.empty();

  @override
  Future<List<Map<String, dynamic>>> listInputDevices() async =>
      (scan['inputDevices'] as List).cast<Map<String, dynamic>>();

  @override
  Stream<Map<String, dynamic>> inputDeviceEvents() => inputEvents.stream;

  @override
  Stream<RawInputEvent> rawInput() => raw.stream;

  @override
  Future<List<Map<String, dynamic>>> storageVolumes() async =>
      (scan['storageVolumes'] as List).cast<Map<String, dynamic>>();

  @override
  Stream<Map<String, dynamic>> storageEvents() => const Stream.empty();

  @override
  Future<String?> pickDirectory() async => null;

  @override
  Future<List<String>> persistedDirectories() async => const [];

  @override
  Future<bool> releaseDirectory(String uri) async => true;

  @override
  Future<bool> isDefaultLauncher() async => false;

  @override
  Future<String> requestDefaultLauncher() async => 'home_settings';

  @override
  Future<String> openHomeSettings() async => 'home_settings';

  @override
  Future<bool> openAndroidSettings() async => true;

  @override
  Future<bool> openAppDetails(String packageName) async => true;

  @override
  Future<List<InstalledApp>> listApps() async =>
      const [InstalledApp('com.example.tv', 'Example TV', true)];

  @override
  Future<Uint8List?> appImage(String packageName, {bool banner = false}) async => null;

  @override
  Future<bool> launchApp(String packageName) async {
    launched.add(packageName);
    return true;
  }

  @override
  Future<Map<String, String?>> installedVersions(List<String> packages) async => {
        for (final p in packages)
          if (installed.containsKey(p)) p: installed[p],
      };

  @override
  Stream<void> homePressed() => const Stream.empty();
}
