/// Hardware capability profile produced by the Device Intelligence Engine.
///
/// Every field that the platform could not report is `null`, and the UI shows
/// it as UNKNOWN. Values are never guessed.
library;

class StorageVolumeInfo {
  const StorageVolumeInfo({
    required this.id,
    required this.description,
    required this.isPrimary,
    required this.isRemovable,
    required this.isEmulated,
    required this.state,
    this.path,
    this.totalBytes,
    this.availableBytes,
    this.kind = StorageKind.unknown,
  });

  final String id;
  final String description;
  final bool isPrimary;
  final bool isRemovable;
  final bool isEmulated;

  /// Android volume state, e.g. `mounted`, `removed`, `unmounted`.
  final String state;
  final String? path;
  final int? totalBytes;
  final int? availableBytes;
  final StorageKind kind;

  bool get isMounted => state == 'mounted' || state == 'mounted_ro';

  factory StorageVolumeInfo.fromMap(Map<String, dynamic> m) => StorageVolumeInfo(
        id: (m['id'] as String?) ?? 'unknown',
        description: (m['description'] as String?) ?? 'Storage',
        isPrimary: m['isPrimary'] == true,
        isRemovable: m['isRemovable'] == true,
        isEmulated: m['isEmulated'] == true,
        state: (m['state'] as String?) ?? 'unknown',
        path: m['path'] as String?,
        totalBytes: (m['totalBytes'] as num?)?.toInt(),
        availableBytes: (m['availableBytes'] as num?)?.toInt(),
        kind: StorageKind.values.firstWhere(
          (k) => k.name == m['kind'],
          orElse: () => StorageKind.unknown,
        ),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'description': description,
        'isPrimary': isPrimary,
        'isRemovable': isRemovable,
        'isEmulated': isEmulated,
        'state': state,
        'path': path,
        'totalBytes': totalBytes,
        'availableBytes': availableBytes,
        'kind': kind.name,
      };
}

enum StorageKind { internal, sdCard, usb, unknown }

class InputDeviceInfo {
  const InputDeviceInfo({
    required this.id,
    required this.name,
    required this.descriptor,
    required this.isExternal,
    required this.classes,
    this.vendorId,
    this.productId,
    this.hasVibrator = false,
    this.axes = const [],
    this.buttons = const [],
    this.controllerNumber,
  });

  final int id;
  final String name;
  final String descriptor;
  final bool isExternal;

  /// Derived from InputDevice sources: gamepad, joystick, dpad, keyboard,
  /// mouse, touchscreen, remote.
  final Set<String> classes;
  final int? vendorId;
  final int? productId;
  final bool hasVibrator;
  final List<String> axes;
  final List<String> buttons;

  /// Android's controller number (1-based) or null when not assigned.
  final int? controllerNumber;

  bool get isGameController =>
      classes.contains('gamepad') || classes.contains('joystick');

  String get vendorProductLabel {
    String hex(int? v) =>
        v == null ? 'UNKNOWN' : '0x${v.toRadixString(16).padLeft(4, '0')}';
    return '${hex(vendorId)}:${hex(productId)}';
  }

  /// Best-effort guess of the transport. Android does not expose the bus type
  /// through public API, so this is labelled as unknown unless the descriptor
  /// name clearly indicates otherwise.
  String get connectionHint {
    final n = name.toLowerCase();
    if (n.contains('bluetooth') || n.contains(' bt')) return 'Bluetooth';
    if (n.contains('2.4g') || n.contains('receiver') || n.contains('wireless')) {
      return 'Wireless receiver';
    }
    return isExternal ? 'External (USB/Bluetooth)' : 'Built-in';
  }

  factory InputDeviceInfo.fromMap(Map<String, dynamic> m) => InputDeviceInfo(
        id: (m['id'] as num).toInt(),
        name: (m['name'] as String?) ?? 'Unknown device',
        descriptor: (m['descriptor'] as String?) ?? '',
        isExternal: m['isExternal'] == true,
        classes: ((m['classes'] as List?) ?? const []).cast<String>().toSet(),
        vendorId: (m['vendorId'] as num?)?.toInt(),
        productId: (m['productId'] as num?)?.toInt(),
        hasVibrator: m['hasVibrator'] == true,
        axes: ((m['axes'] as List?) ?? const []).cast<String>(),
        buttons: ((m['buttons'] as List?) ?? const []).cast<String>(),
        controllerNumber: (m['controllerNumber'] as num?)?.toInt(),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'descriptor': descriptor,
        'isExternal': isExternal,
        'classes': classes.toList(),
        'vendorId': vendorId,
        'productId': productId,
        'hasVibrator': hasVibrator,
        'axes': axes,
        'buttons': buttons,
        'controllerNumber': controllerNumber,
      };
}

class HardwareProfile {
  const HardwareProfile({
    required this.scannedAt,
    this.manufacturer,
    this.brand,
    this.model,
    this.device,
    this.product,
    this.board,
    this.hardware,
    this.socModel,
    this.socManufacturer,
    this.androidVersion,
    this.sdkInt,
    this.buildId,
    this.buildFingerprint,
    this.supportedAbis = const [],
    this.supported32BitAbis = const [],
    this.supported64BitAbis = const [],
    this.cpuModel,
    this.cpuCores,
    this.cpuMaxFreqKhz,
    this.cpuParts = const [],
    this.cpuImplementer,
    this.cpuFeatures = const [],
    this.totalRamBytes,
    this.availableRamBytes,
    this.lowMemory,
    this.lowMemoryThresholdBytes,
    this.isLowRamDevice,
    this.memoryClassMb,
    this.largeMemoryClassMb,
    this.glVendor,
    this.glRenderer,
    this.glVersion,
    this.glEsVersion,
    this.vulkanSupported,
    this.vulkanApiVersion,
    this.vulkanHardwareLevel,
    this.displayWidth,
    this.displayHeight,
    this.refreshRate,
    this.densityDpi,
    this.isTelevision,
    this.storageVolumes = const [],
    this.inputDevices = const [],
  });

  final DateTime scannedAt;

  // Device
  final String? manufacturer;
  final String? brand;
  final String? model;
  final String? device;
  final String? product;
  final String? board;
  final String? hardware;
  final String? socModel;
  final String? socManufacturer;
  final String? androidVersion;
  final int? sdkInt;
  final String? buildId;
  final String? buildFingerprint;

  // CPU
  final List<String> supportedAbis;
  final List<String> supported32BitAbis;
  final List<String> supported64BitAbis;
  final String? cpuModel;
  final int? cpuCores;
  final int? cpuMaxFreqKhz;

  /// ARM "CPU part" identifiers (e.g. `0xd03` = Cortex-A53), one per core type.
  final List<String> cpuParts;
  final String? cpuImplementer;
  final List<String> cpuFeatures;

  // RAM
  final int? totalRamBytes;
  final int? availableRamBytes;
  final bool? lowMemory;
  final int? lowMemoryThresholdBytes;
  final bool? isLowRamDevice;
  final int? memoryClassMb;
  final int? largeMemoryClassMb;

  // GPU
  final String? glVendor;
  final String? glRenderer;
  final String? glVersion;

  /// OpenGL ES version declared by the device, e.g. `3.2`.
  final String? glEsVersion;
  final bool? vulkanSupported;
  final String? vulkanApiVersion;
  final int? vulkanHardwareLevel;

  // Display
  final int? displayWidth;
  final int? displayHeight;
  final double? refreshRate;
  final int? densityDpi;
  final bool? isTelevision;

  // Storage / input
  final List<StorageVolumeInfo> storageVolumes;
  final List<InputDeviceInfo> inputDevices;

  bool get supportsArm64 => supported64BitAbis.contains('arm64-v8a');
  bool get supportsArmV7 => supportedAbis.contains('armeabi-v7a');

  /// True when the CPU is 64-bit capable but the OS only exposes 32-bit ABIs.
  /// This is common on budget TV boxes and blocks arm64-only emulators.
  bool get is32BitUserspaceOn64BitCpu =>
      supported64BitAbis.isEmpty &&
      cpuFeatures.any((f) => f == 'asimd' || f == 'aes' || f == 'crc32') &&
      cpuParts.any((p) => _armv8Parts.contains(p));

  static const _armv8Parts = {
    '0xd03', '0xd04', '0xd05', '0xd07', '0xd08', '0xd09', '0xd0a', '0xd0b',
    '0xd0c', '0xd0d', '0xd0e', '0xd41', '0xd44', '0xd46', '0xd47', '0xd48',
  };

  double? get glEsVersionNumber =>
      glEsVersion == null ? null : double.tryParse(glEsVersion!);

  String? get aspectRatioLabel {
    final w = displayWidth, h = displayHeight;
    if (w == null || h == null || w == 0 || h == 0) return null;
    int gcd(int a, int b) => b == 0 ? a : gcd(b, a % b);
    final g = gcd(w, h);
    final rw = w ~/ g, rh = h ~/ g;
    if (rw == 16 && rh == 9) return '16:9';
    return '$rw:$rh (${(w / h).toStringAsFixed(2)}:1)';
  }

  List<InputDeviceInfo> get gameControllers =>
      inputDevices.where((d) => d.isGameController).toList();

  HardwareProfile copyWith({
    List<StorageVolumeInfo>? storageVolumes,
    List<InputDeviceInfo>? inputDevices,
    int? availableRamBytes,
  }) =>
      HardwareProfile.fromMap({
        ...toMap(),
        if (storageVolumes != null)
          'storageVolumes': storageVolumes.map((e) => e.toMap()).toList(),
        if (inputDevices != null)
          'inputDevices': inputDevices.map((e) => e.toMap()).toList(),
        'availableRamBytes': ?availableRamBytes,
      });

  factory HardwareProfile.fromMap(Map<String, dynamic> m) {
    List<String> strList(String k) =>
        ((m[k] as List?) ?? const []).map((e) => e.toString()).toList();
    int? i(String k) => (m[k] as num?)?.toInt();
    String? s(String k) {
      final v = m[k];
      if (v == null) return null;
      final t = v.toString().trim();
      return t.isEmpty || t.toLowerCase() == 'unknown' ? null : t;
    }

    return HardwareProfile(
      scannedAt: m['scannedAt'] is String
          ? DateTime.parse(m['scannedAt'] as String)
          : DateTime.now(),
      manufacturer: s('manufacturer'),
      brand: s('brand'),
      model: s('model'),
      device: s('device'),
      product: s('product'),
      board: s('board'),
      hardware: s('hardware'),
      socModel: s('socModel'),
      socManufacturer: s('socManufacturer'),
      androidVersion: s('androidVersion'),
      sdkInt: i('sdkInt'),
      buildId: s('buildId'),
      buildFingerprint: s('buildFingerprint'),
      supportedAbis: strList('supportedAbis'),
      supported32BitAbis: strList('supported32BitAbis'),
      supported64BitAbis: strList('supported64BitAbis'),
      cpuModel: s('cpuModel'),
      cpuCores: i('cpuCores'),
      cpuMaxFreqKhz: i('cpuMaxFreqKhz'),
      cpuParts: strList('cpuParts'),
      cpuImplementer: s('cpuImplementer'),
      cpuFeatures: strList('cpuFeatures'),
      totalRamBytes: i('totalRamBytes'),
      availableRamBytes: i('availableRamBytes'),
      lowMemory: m['lowMemory'] as bool?,
      lowMemoryThresholdBytes: i('lowMemoryThresholdBytes'),
      isLowRamDevice: m['isLowRamDevice'] as bool?,
      memoryClassMb: i('memoryClassMb'),
      largeMemoryClassMb: i('largeMemoryClassMb'),
      glVendor: s('glVendor'),
      glRenderer: s('glRenderer'),
      glVersion: s('glVersion'),
      glEsVersion: s('glEsVersion'),
      vulkanSupported: m['vulkanSupported'] as bool?,
      vulkanApiVersion: s('vulkanApiVersion'),
      vulkanHardwareLevel: i('vulkanHardwareLevel'),
      displayWidth: i('displayWidth'),
      displayHeight: i('displayHeight'),
      refreshRate: (m['refreshRate'] as num?)?.toDouble(),
      densityDpi: i('densityDpi'),
      isTelevision: m['isTelevision'] as bool?,
      storageVolumes: ((m['storageVolumes'] as List?) ?? const [])
          .map((e) => StorageVolumeInfo.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      inputDevices: ((m['inputDevices'] as List?) ?? const [])
          .map((e) => InputDeviceInfo.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
        'scannedAt': scannedAt.toIso8601String(),
        'manufacturer': manufacturer,
        'brand': brand,
        'model': model,
        'device': device,
        'product': product,
        'board': board,
        'hardware': hardware,
        'socModel': socModel,
        'socManufacturer': socManufacturer,
        'androidVersion': androidVersion,
        'sdkInt': sdkInt,
        'buildId': buildId,
        'buildFingerprint': buildFingerprint,
        'supportedAbis': supportedAbis,
        'supported32BitAbis': supported32BitAbis,
        'supported64BitAbis': supported64BitAbis,
        'cpuModel': cpuModel,
        'cpuCores': cpuCores,
        'cpuMaxFreqKhz': cpuMaxFreqKhz,
        'cpuParts': cpuParts,
        'cpuImplementer': cpuImplementer,
        'cpuFeatures': cpuFeatures,
        'totalRamBytes': totalRamBytes,
        'availableRamBytes': availableRamBytes,
        'lowMemory': lowMemory,
        'lowMemoryThresholdBytes': lowMemoryThresholdBytes,
        'isLowRamDevice': isLowRamDevice,
        'memoryClassMb': memoryClassMb,
        'largeMemoryClassMb': largeMemoryClassMb,
        'glVendor': glVendor,
        'glRenderer': glRenderer,
        'glVersion': glVersion,
        'glEsVersion': glEsVersion,
        'vulkanSupported': vulkanSupported,
        'vulkanApiVersion': vulkanApiVersion,
        'vulkanHardwareLevel': vulkanHardwareLevel,
        'displayWidth': displayWidth,
        'displayHeight': displayHeight,
        'refreshRate': refreshRate,
        'densityDpi': densityDpi,
        'isTelevision': isTelevision,
        'storageVolumes': storageVolumes.map((e) => e.toMap()).toList(),
        'inputDevices': inputDevices.map((e) => e.toMap()).toList(),
      };
}
