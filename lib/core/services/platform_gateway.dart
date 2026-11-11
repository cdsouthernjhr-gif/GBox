import 'dart:async';

import 'package:flutter/services.dart';

/// Connectivity snapshot. Offline is a normal, fully supported state.
class ConnectivityStatus {
  const ConnectivityStatus({
    required this.connected,
    required this.validated,
    required this.transport,
  });

  static const offline =
      ConnectivityStatus(connected: false, validated: false, transport: 'none');

  final bool connected;

  /// Android confirmed the network actually reaches the internet.
  final bool validated;
  final String transport;

  bool get isOnline => connected && validated;

  factory ConnectivityStatus.fromMap(Map<dynamic, dynamic> m) =>
      ConnectivityStatus(
        connected: m['connected'] == true,
        validated: m['validated'] == true,
        transport: (m['transport'] as String?) ?? 'none',
      );
}

class InstalledApp {
  const InstalledApp(this.packageName, this.label, this.isTvApp);
  final String packageName;
  final String label;
  final bool isTvApp;
}

/// Raw event from the controller test stream.
class RawInputEvent {
  const RawInputEvent({
    required this.type,
    required this.deviceId,
    this.keyName,
    this.keyCode,
    this.isDown,
    this.axes = const {},
  });

  final String type; // key | motion
  final int deviceId;
  final String? keyName;
  final int? keyCode;
  final bool? isDown;
  final Map<String, double> axes;

  factory RawInputEvent.fromMap(Map<dynamic, dynamic> m) => RawInputEvent(
        type: m['type'] as String,
        deviceId: (m['deviceId'] as num).toInt(),
        keyName: m['keyName'] as String?,
        keyCode: (m['keyCode'] as num?)?.toInt(),
        isDown: m['action'] == null ? null : m['action'] == 'down',
        axes: {
          for (final e in ((m['axes'] as Map?) ?? const {}).entries)
            e.key as String: (e.value as num).toDouble(),
        },
      );
}

/// Boundary between Flutter and the Android native layer. The UI never calls
/// MethodChannels directly; it goes through services that use this gateway.
abstract class PlatformGateway {
  Future<Map<String, dynamic>> scanHardware();
  Future<Map<String, dynamic>> memoryInfo();

  Future<ConnectivityStatus> connectivity();
  Stream<ConnectivityStatus> connectivityChanges();

  Future<List<Map<String, dynamic>>> listInputDevices();
  Stream<Map<String, dynamic>> inputDeviceEvents();
  Stream<RawInputEvent> rawInput();

  /// Pushes key remaps / dead zones (by InputDevice descriptor) to native.
  Future<void> setInputConfig({
    required Map<String, Map<int, int>> remaps,
    required Map<String, double> deadZones,
    required bool stickNavigation,
  });

  /// One-shot rumble; false if the controller has no vibrator.
  Future<bool> vibrate(int deviceId, {int durationMs = 250, int amplitude = 200});

  Future<List<Map<String, dynamic>>> storageVolumes();
  Stream<Map<String, dynamic>> storageEvents();
  Future<String?> pickDirectory();
  Future<List<String>> persistedDirectories();
  Future<bool> releaseDirectory(String uri);

  // ---- ROM manager (Phase 2) ----
  /// Recursively lists files under a SAF tree whose extension is in
  /// [extensions]. Returns `{files: [...], folders: n, truncated: bool}`.
  Future<Map<String, dynamic>> scanTree(String treeUri, Set<String> extensions,
      {int maxDepth = 8, int maxFiles = 20000});
  Future<bool> treeAccessible(String treeUri);
  Future<List<bool>> existsMany(List<String> uris);

  /// `{sha1, crc32, size}` of the whole file.
  Future<Map<String, dynamic>> hashFile(String uri);
  Future<Uint8List> readBytes(String uri, {int offset = 0, required int length});

  /// Downscaled JPEG copy of an image into [destPath]; null if not an image.
  Future<String?> importImage(String uri, String destPath, {int maxDim = 600});
  Future<bool> deleteFile(String uri);

  /// Copies a document/file to a local path; returns bytes copied.
  Future<int> copyToLocal(String uri, String destPath);

  /// Overwrites an existing document/file with a local file.
  Future<int> copyFromLocal(String srcPath, String destUri);

  /// Live performance data (memory, CPU frequencies, thermal zones, …).
  Future<Map<String, dynamic>> performanceSnapshot();

  /// Free bytes on the volume holding [path], or null if unknown.
  Future<int?> freeSpace(String path);

  /// `[{uri, name, size}]` for picked documents.
  Future<List<Map<String, dynamic>>> describeFiles(List<String> uris);
  Future<List<String>> pickFiles();
  Future<String?> pickImage();

  // ---- Emulator launching (Phase 3) ----
  /// Starts an intent spec (see IntentSpec.toMap). `{ok, code?, error?}`.
  Future<Map<String, dynamic>> launchIntent(Map<String, Object?> spec);

  /// FileProvider URI for a file in the GAMEBOX game folders, or null.
  Future<String?> shareableUri(String path);

  Future<bool> isDefaultLauncher();
  Future<String> requestDefaultLauncher();
  Future<String> openHomeSettings();
  Future<bool> openAndroidSettings();
  Future<bool> openAppDetails(String packageName);
  Future<List<InstalledApp>> listApps();
  Future<Uint8List?> appImage(String packageName, {bool banner = false});
  Future<bool> launchApp(String packageName);
  Future<Map<String, String?>> installedVersions(List<String> packages);

  /// Fires when HOME is pressed while GAMEBOX is already in front.
  Stream<void> homePressed();
}

class MethodChannelGateway implements PlatformGateway {
  MethodChannelGateway() {
    _launcher.setMethodCallHandler((call) async {
      if (call.method == 'onHomePressed') _home.add(null);
    });
  }

  static const _device = MethodChannel('gamebox/device');
  static const _launcher = MethodChannel('gamebox/launcher');
  static const _controllers = MethodChannel('gamebox/controllers');
  static const _storage = MethodChannel('gamebox/storage');
  static const _emulator = MethodChannel('gamebox/emulator');
  static const _controllerEvents = EventChannel('gamebox/controller_events');
  static const _rawInput = EventChannel('gamebox/raw_input');
  static const _connectivity = EventChannel('gamebox/connectivity');
  static const _storageEvents = EventChannel('gamebox/storage_events');

  final _home = StreamController<void>.broadcast();

  static Map<String, dynamic> _map(Object? v) =>
      v == null ? <String, dynamic>{} : _deep(v) as Map<String, dynamic>;

  /// Converts platform maps (`Map<Object?, Object?>`) into JSON-like Dart maps.
  static Object? _deep(Object? v) {
    if (v is Map) {
      return <String, dynamic>{
        for (final e in v.entries) e.key.toString(): _deep(e.value),
      };
    }
    if (v is List) return v.map(_deep).toList();
    return v;
  }

  @override
  Future<Map<String, dynamic>> scanHardware() async =>
      _map(await _device.invokeMethod<Object?>('scan'));

  @override
  Future<Map<String, dynamic>> memoryInfo() async =>
      _map(await _device.invokeMethod<Object?>('memory'));

  @override
  Future<ConnectivityStatus> connectivity() async {
    final m = await _device.invokeMethod<Map<dynamic, dynamic>>('connectivity');
    return m == null ? ConnectivityStatus.offline : ConnectivityStatus.fromMap(m);
  }

  @override
  Stream<ConnectivityStatus> connectivityChanges() => _connectivity
      .receiveBroadcastStream()
      .map((e) => ConnectivityStatus.fromMap(e as Map));

  @override
  Future<List<Map<String, dynamic>>> listInputDevices() async {
    final list = await _controllers.invokeMethod<List<Object?>>('list');
    return (list ?? const []).map(_map).toList();
  }

  @override
  Stream<Map<String, dynamic>> inputDeviceEvents() =>
      _controllerEvents.receiveBroadcastStream().map(_map);

  @override
  Future<void> setInputConfig({
    required Map<String, Map<int, int>> remaps,
    required Map<String, double> deadZones,
    required bool stickNavigation,
  }) =>
      _controllers.invokeMethod<bool>('setInputConfig', {
        'remaps': remaps,
        'deadZones': deadZones,
        'stickNavigation': stickNavigation,
      });

  @override
  Future<bool> vibrate(int deviceId, {int durationMs = 250, int amplitude = 200}) async =>
      await _controllers.invokeMethod<bool>(
          'vibrate', {'deviceId': deviceId, 'durationMs': durationMs, 'amplitude': amplitude}) ??
      false;

  @override
  Stream<RawInputEvent> rawInput() => _rawInput
      .receiveBroadcastStream()
      .map((e) => RawInputEvent.fromMap(e as Map));

  @override
  Future<List<Map<String, dynamic>>> storageVolumes() async {
    final list = await _storage.invokeMethod<List<Object?>>('volumes');
    return (list ?? const []).map(_map).toList();
  }

  @override
  Stream<Map<String, dynamic>> storageEvents() =>
      _storageEvents.receiveBroadcastStream().map(_map);

  @override
  Future<String?> pickDirectory() => _storage.invokeMethod<String>('pickDirectory');

  @override
  Future<List<String>> persistedDirectories() async {
    final list = await _storage.invokeMethod<List<Object?>>('persistedDirectories');
    return (list ?? const []).map((e) => _map(e)['uri'] as String).toList();
  }

  @override
  Future<bool> releaseDirectory(String uri) async =>
      await _storage.invokeMethod<bool>('releaseDirectory', {'uri': uri}) ?? false;

  @override
  Future<Map<String, dynamic>> scanTree(String treeUri, Set<String> extensions,
          {int maxDepth = 8, int maxFiles = 20000}) async =>
      _map(await _storage.invokeMethod<Object?>('scanTree', {
        'uri': treeUri,
        'extensions': extensions.toList(),
        'maxDepth': maxDepth,
        'maxFiles': maxFiles,
      }));

  @override
  Future<bool> treeAccessible(String treeUri) async =>
      await _storage.invokeMethod<bool>('treeAccessible', {'uri': treeUri}) ?? false;

  @override
  Future<List<bool>> existsMany(List<String> uris) async {
    final r = await _storage.invokeMethod<List<Object?>>('existsMany', {'uris': uris});
    return (r ?? const []).map((e) => e == true).toList();
  }

  @override
  Future<Map<String, dynamic>> hashFile(String uri) async =>
      _map(await _storage.invokeMethod<Object?>('hash', {'uri': uri}));

  @override
  Future<Uint8List> readBytes(String uri, {int offset = 0, required int length}) async =>
      await _storage.invokeMethod<Uint8List>('readBytes', {'uri': uri, 'offset': offset, 'length': length}) ??
      Uint8List(0);

  @override
  Future<String?> importImage(String uri, String destPath, {int maxDim = 600}) =>
      _storage.invokeMethod<String>('importImage', {'uri': uri, 'dest': destPath, 'maxDim': maxDim});

  @override
  Future<int?> freeSpace(String path) async =>
      (await _storage.invokeMethod<Object?>('freeSpace', {'path': path}) as num?)?.toInt();

  @override
  Future<int> copyToLocal(String uri, String destPath) async =>
      ((await _storage.invokeMethod<Object?>('copyToLocal', {'uri': uri, 'dest': destPath})) as num).toInt();

  @override
  Future<int> copyFromLocal(String srcPath, String destUri) async =>
      ((await _storage.invokeMethod<Object?>('copyFromLocal', {'src': srcPath, 'dest': destUri})) as num).toInt();

  @override
  Future<Map<String, dynamic>> performanceSnapshot() async =>
      _map(await _device.invokeMethod<Object?>('performance'));

  @override
  Future<bool> deleteFile(String uri) async =>
      await _storage.invokeMethod<bool>('deleteFile', {'uri': uri}) ?? false;

  @override
  Future<List<Map<String, dynamic>>> describeFiles(List<String> uris) async =>
      ((await _storage.invokeMethod<List<Object?>>('describe', {'uris': uris})) ?? const []).map(_map).toList();

  @override
  Future<List<String>> pickFiles() async =>
      ((await _storage.invokeMethod<List<Object?>>('pickFiles')) ?? const []).cast<String>();

  @override
  Future<String?> pickImage() async {
    final r = (await _storage.invokeMethod<List<Object?>>('pickImage')) ?? const [];
    return r.isEmpty ? null : r.first as String;
  }

  @override
  Future<Map<String, dynamic>> launchIntent(Map<String, Object?> spec) async =>
      _map(await _emulator.invokeMethod<Object?>('launch', spec));

  @override
  Future<String?> shareableUri(String path) => _emulator.invokeMethod<String>('shareableUri', {'path': path});

  @override
  Future<bool> isDefaultLauncher() async =>
      await _launcher.invokeMethod<bool>('isDefaultLauncher') ?? false;

  @override
  Future<String> requestDefaultLauncher() async =>
      await _launcher.invokeMethod<String>('requestDefaultLauncher') ?? 'unavailable';

  @override
  Future<String> openHomeSettings() async =>
      await _launcher.invokeMethod<String>('openHomeSettings') ?? 'unavailable';

  @override
  Future<bool> openAndroidSettings() async =>
      await _launcher.invokeMethod<bool>('openAndroidSettings') ?? false;

  @override
  Future<bool> openAppDetails(String packageName) async =>
      await _launcher.invokeMethod<bool>(
              'openAppDetails', {'packageName': packageName}) ??
          false;

  @override
  Future<List<InstalledApp>> listApps() async {
    final list = await _launcher.invokeMethod<List<Object?>>('listApps');
    return (list ?? const []).map((e) {
      final m = _map(e);
      return InstalledApp(
          m['packageName'] as String, m['label'] as String, m['isTvApp'] == true);
    }).toList();
  }

  @override
  Future<Uint8List?> appImage(String packageName, {bool banner = false}) =>
      _launcher.invokeMethod<Uint8List>(
          'appImage', {'packageName': packageName, 'banner': banner});

  @override
  Future<bool> launchApp(String packageName) async =>
      await _launcher.invokeMethod<bool>('launchApp', {'packageName': packageName}) ??
          false;

  @override
  Future<Map<String, String?>> installedVersions(List<String> packages) async {
    final m = await _launcher.invokeMethod<Map<Object?, Object?>>(
        'installedVersions', {'packages': packages});
    return {
      for (final e in (m ?? const {}).entries) e.key as String: e.value as String?,
    };
  }

  @override
  Stream<void> homePressed() => _home.stream;
}
