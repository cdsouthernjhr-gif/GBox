import 'dart:async';
import 'dart:io';

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

  Map<String, Object?>? lastInputConfig;
  final vibrations = <int>[];

  @override
  Future<void> setInputConfig({
    required Map<String, Map<int, int>> remaps,
    required Map<String, double> deadZones,
    required bool stickNavigation,
  }) async =>
      lastInputConfig = {'remaps': remaps, 'deadZones': deadZones, 'stickNavigation': stickNavigation};

  @override
  Future<bool> vibrate(int deviceId, {int durationMs = 250, int amplitude = 200}) async {
    vibrations.add(deviceId);
    return true;
  }

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

  // ---- ROM manager fakes ----
  /// Simulated SAF trees: tree URI → files (`{uri,name,dir,size}`).
  final trees = <String, List<Map<String, dynamic>>>{};
  final inaccessibleTrees = <String>{};

  /// Contents of simulated `content://` documents.
  final documents = <String, Uint8List>{};
  final deleted = <String>[];
  List<String> nextPickedFiles = const [];
  String? nextPickedImage;

  Uint8List _bytesOf(String uri) {
    if (uri.startsWith('content://')) {
      final b = documents[uri];
      if (b == null) throw StateError('No such document $uri');
      return b;
    }
    return File(uri).readAsBytesSync();
  }

  @override
  Future<Map<String, dynamic>> scanTree(String treeUri, Set<String> extensions,
          {int maxDepth = 8, int maxFiles = 20000}) async =>
      {
        'files': [
          for (final f in trees[treeUri] ?? const <Map<String, dynamic>>[])
            if (extensions.contains((f['name'] as String).split('.').last.toLowerCase())) f,
        ],
        'folders': 1,
        'truncated': false,
      };

  @override
  Future<bool> treeAccessible(String treeUri) async =>
      trees.containsKey(treeUri) && !inaccessibleTrees.contains(treeUri);

  @override
  Future<List<bool>> existsMany(List<String> uris) async => [
        for (final u in uris) u.startsWith('content://') ? documents.containsKey(u) : File(u).existsSync(),
      ];

  @override
  Future<Map<String, dynamic>> hashFile(String uri) async {
    final b = _bytesOf(uri);
    // Deterministic stand-in for SHA-1 (FNV-1a 64-bit); equality is all the
    // tests need.
    var h = 0xcbf29ce484222325;
    for (final x in b) {
      h = ((h ^ x) * 0x100000001b3) & 0x7fffffffffffffff;
    }
    return {'sha1': h.toRadixString(16).padLeft(40, '0'), 'crc32': '00000000', 'size': b.length};
  }

  @override
  Future<Uint8List> readBytes(String uri, {int offset = 0, required int length}) async {
    final b = _bytesOf(uri);
    final end = (offset + length).clamp(0, b.length);
    return Uint8List.fromList(b.sublist(offset.clamp(0, b.length), end));
  }

  @override
  Future<String?> importImage(String uri, String destPath, {int maxDim = 600}) async {
    final b = _bytesOf(uri);
    final f = File(destPath)..createSync(recursive: true);
    f.writeAsBytesSync(b);
    return destPath;
  }

  int? freeBytes;

  @override
  Future<int> copyToLocal(String uri, String destPath) async {
    final b = _bytesOf(uri);
    File(destPath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(b);
    return b.length;
  }

  @override
  Future<int> copyFromLocal(String srcPath, String destUri) async {
    final b = File(srcPath).readAsBytesSync();
    if (destUri.startsWith('content://')) {
      documents[destUri] = b;
    } else {
      File(destUri).writeAsBytesSync(b);
    }
    return b.length;
  }

  Map<String, dynamic> performance = {
    'totalRamBytes': 4 * 1024 * 1024 * 1024,
    'availableRamBytes': 2 * 1024 * 1024 * 1024,
    'cpuCurFreqKhz': [1200000, 1800000],
    'procStatReadable': false,
    'thermalZones': [
      {'zone': 'thermal_zone0', 'type': 'soc_thermal', 'celsius': 52.0},
    ],
    'appCpuTimeMs': 1000,
    'uptimeMs': 100000,
  };

  @override
  Future<Map<String, dynamic>> performanceSnapshot() async => performance;

  @override
  Future<int?> freeSpace(String path) async => freeBytes;

  @override
  Future<bool> deleteFile(String uri) async {
    deleted.add(uri);
    if (uri.startsWith('content://')) return documents.remove(uri) != null;
    final f = File(uri);
    if (!f.existsSync()) return false;
    f.deleteSync();
    return true;
  }

  @override
  Future<List<Map<String, dynamic>>> describeFiles(List<String> uris) async => [
        for (final u in uris)
          {'uri': u, 'name': Uri.decodeComponent(u).split(RegExp('[/:]')).last, 'size': documents[u]?.length},
      ];

  @override
  Future<List<String>> pickFiles() async => nextPickedFiles;

  @override
  Future<String?> pickImage() async => nextPickedImage;

  // ---- launching fakes ----
  final launchedSpecs = <Map<String, Object?>>[];
  Map<String, dynamic> nextLaunchResult = {'ok': true};
  String? fileProviderBase;

  @override
  Future<Map<String, dynamic>> launchIntent(Map<String, Object?> spec) async {
    launchedSpecs.add(spec);
    return nextLaunchResult;
  }

  @override
  Future<String?> shareableUri(String path) async {
    final base = fileProviderBase;
    if (base == null || !path.startsWith(base)) return null;
    return 'content://com.gamebox.console.files/gamebox/${path.substring(base.length)}';
  }

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
