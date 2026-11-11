/// Parses Linux `/proc/cpuinfo` text as found on ARM Android devices.
///
/// Formats vary widely between kernels and vendors, so every field is
/// optional. Unknown values stay `null`.
library;

class CpuInfo {
  const CpuInfo({
    this.processorCount,
    this.hardware,
    this.modelName,
    this.implementer,
    this.parts = const [],
    this.features = const [],
  });

  final int? processorCount;
  final String? hardware;
  final String? modelName;
  final String? implementer;

  /// Distinct `CPU part` values in order of appearance (lower-case hex).
  final List<String> parts;
  final List<String> features;

  /// Human readable core description, e.g. `4x Cortex-A53` or
  /// `Cortex-A73 + Cortex-A53`.
  String? get coreDescription {
    if (parts.isEmpty) return null;
    final names = parts.map((p) => armCoreName(implementer, p) ?? 'part $p');
    return names.join(' + ');
  }
}

/// Known ARM Ltd (implementer 0x41) core part numbers.
const Map<String, String> armCoreNames = {
  '0xc05': 'Cortex-A5',
  '0xc07': 'Cortex-A7',
  '0xc08': 'Cortex-A8',
  '0xc09': 'Cortex-A9',
  '0xc0d': 'Cortex-A12',
  '0xc0e': 'Cortex-A17',
  '0xc0f': 'Cortex-A15',
  '0xd03': 'Cortex-A53',
  '0xd04': 'Cortex-A35',
  '0xd05': 'Cortex-A55',
  '0xd07': 'Cortex-A57',
  '0xd08': 'Cortex-A72',
  '0xd09': 'Cortex-A73',
  '0xd0a': 'Cortex-A75',
  '0xd0b': 'Cortex-A76',
  '0xd0d': 'Cortex-A77',
  '0xd41': 'Cortex-A78',
  '0xd44': 'Cortex-X1',
  '0xd46': 'Cortex-A510',
  '0xd47': 'Cortex-A710',
  '0xd48': 'Cortex-X2',
};

/// Relative per-core performance class used by the adaptive engine.
/// 0 = legacy 32-bit little core, 1 = in-order ARMv8 little core,
/// 2 = early out-of-order big core, 3 = modern big core.
const Map<String, int> armCoreClass = {
  '0xc05': 0, '0xc07': 0, '0xc08': 0, '0xc09': 0,
  '0xc0d': 1, '0xc0e': 1, '0xc0f': 1,
  '0xd04': 1, '0xd03': 1, '0xd05': 1, '0xd46': 1,
  '0xd07': 2, '0xd08': 2, '0xd09': 2,
  '0xd0a': 3, '0xd0b': 3, '0xd0d': 3, '0xd41': 3, '0xd44': 3, '0xd47': 3,
  '0xd48': 3,
};

String? armCoreName(String? implementer, String part) {
  if (implementer != null && implementer.toLowerCase() != '0x41') return null;
  return armCoreNames[part.toLowerCase()];
}

CpuInfo parseCpuInfo(String? raw) {
  if (raw == null || raw.trim().isEmpty) return const CpuInfo();
  var processors = 0;
  String? hardware, modelName, implementer;
  final parts = <String>[];
  final features = <String>{};

  for (final line in raw.split('\n')) {
    final idx = line.indexOf(':');
    if (idx < 0) continue;
    final key = line.substring(0, idx).trim().toLowerCase();
    final value = line.substring(idx + 1).trim();
    switch (key) {
      case 'processor':
        // Old kernels use "Processor : ARMv7 Processor rev 5 (v7l)" (a model
        // name) while newer ones use "processor : 0" (an index).
        if (int.tryParse(value) != null) {
          processors++;
        } else if (value.isNotEmpty) {
          modelName ??= value;
        }
      case 'model name':
        if (value.isNotEmpty) modelName ??= value;
      case 'hardware':
        if (value.isNotEmpty) hardware ??= value;
      case 'cpu implementer':
        implementer ??= value.toLowerCase();
      case 'cpu part':
        final p = value.toLowerCase();
        if (!parts.contains(p)) parts.add(p);
      case 'features':
        features.addAll(value.split(RegExp(r'\s+')).where((f) => f.isNotEmpty));
    }
  }

  return CpuInfo(
    processorCount: processors == 0 ? null : processors,
    hardware: hardware,
    modelName: modelName,
    implementer: implementer,
    parts: parts,
    features: features.toList()..sort(),
  );
}
