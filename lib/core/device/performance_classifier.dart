/// Adaptive Gaming Engine: classifies a device into a performance tier and
/// estimates per-console / per-emulator compatibility.
///
/// The tier combines CPU, GPU, RAM, graphics API and ABI evidence; RAM alone
/// never decides it. All results derived purely from hardware are labelled
/// [EvidenceLevel.hardwareEstimate]. No FPS figures are ever produced here.
library;

import '../../domain/entities/hardware_profile.dart';
import '../../domain/entities/performance_tier.dart';
import '../constants/console_catalog.dart';
import 'cpuinfo_parser.dart';

class AxisScore {
  const AxisScore(this.name, this.score, this.reason);
  final String name;

  /// 0..3, or null when the axis could not be evaluated.
  final int? score;
  final String reason;
}

class DeviceClassification {
  const DeviceClassification({
    required this.tier,
    required this.axes,
    required this.caps,
    required this.confidence,
  });

  final PerformanceTier tier;
  final List<AxisScore> axes;

  /// Human-readable limits that lowered the tier.
  final List<String> caps;

  /// `high`, `medium` or `low` depending on how much data was detected.
  final String confidence;
}

class CompatibilityEstimate {
  const CompatibilityEstimate({
    required this.rating,
    required this.evidence,
    required this.reasons,
  });

  final CompatibilityRating rating;
  final EvidenceLevel evidence;
  final List<String> reasons;
}

class PerformanceClassifier {
  const PerformanceClassifier();

  static const _tiers = PerformanceTier.values;

  AxisScore scoreCpu(HardwareProfile p) {
    final classes = [
      for (final part in p.cpuParts)
        if (p.cpuImplementer == null || p.cpuImplementer == '0x41')
          if (armCoreClass[part] != null) armCoreClass[part]!,
    ];
    final cores = p.cpuCores;
    final ghz = p.cpuMaxFreqKhz == null ? null : p.cpuMaxFreqKhz! / 1e6;

    if (classes.isNotEmpty) {
      var score = classes.reduce((a, b) => a > b ? a : b);
      final names = p.cpuParts
          .map((x) => armCoreName(p.cpuImplementer, x) ?? x)
          .join(' + ');
      var reason = 'Cores: $names';
      // A fast, many-core little-core design can carry standard workloads.
      if (score == 1 && (cores ?? 0) >= 8 && (ghz ?? 0) >= 1.8) {
        score = 2;
        reason += ' (8+ cores at ${ghz!.toStringAsFixed(1)} GHz)';
      }
      // Slow single/dual-core parts.
      if ((cores ?? 4) < 4 && score > 0) {
        score -= 1;
        reason += ' (fewer than 4 cores)';
      }
      return AxisScore('CPU', score, reason);
    }

    if (cores == null) {
      return const AxisScore('CPU', null, 'CPU core type not reported');
    }
    // Fallback when core part ids are unavailable (non-ARM or hidden).
    int score;
    if (cores >= 6 && (ghz ?? 0) >= 2.2) {
      score = 2;
    } else if (cores >= 4 && (ghz == null || ghz >= 1.4)) {
      score = 1;
    } else {
      score = 0;
    }
    return AxisScore('CPU', score,
        '$cores cores${ghz != null ? ' @ ${ghz.toStringAsFixed(1)} GHz' : ''} (core type unknown)');
  }

  AxisScore scoreGpu(HardwareProfile p) {
    final renderer = (p.glRenderer ?? '').toLowerCase();
    final es = p.glEsVersionNumber;

    // Known renderer families take precedence over API level alone.
    final known = _knownGpuScore(renderer);
    if (known != null) {
      return AxisScore('GPU', known, 'Renderer: ${p.glRenderer}');
    }
    if (es == null) {
      return const AxisScore('GPU', null, 'OpenGL ES version not reported');
    }
    if (es < 3.0) {
      return AxisScore('GPU', 0, 'OpenGL ES $es only');
    }
    if (p.vulkanSupported == true && es >= 3.1) {
      return AxisScore('GPU', 2, 'OpenGL ES $es + Vulkan');
    }
    return AxisScore('GPU', 1, 'OpenGL ES $es');
  }

  int? _knownGpuScore(String r) {
    if (r.isEmpty) return null;
    if (RegExp(r'mali-(300|400|450|470)').hasMatch(r)) return 0;
    if (r.contains('sgx') || r.contains('videocore iv')) return 0;
    if (RegExp(r'mali-t(6|7)\d\d').hasMatch(r)) return 1;
    if (RegExp(r'mali-g(31|51|52)\b').hasMatch(r)) {
      return r.contains('g52') ? 2 : 1;
    }
    if (RegExp(r'powervr.*(ge8|8xe|9xe)').hasMatch(r)) return 1;
    if (RegExp(r'mali-t8\d\d').hasMatch(r)) return 2;
    if (RegExp(r'mali-g(57|68|71|72|76)\b').hasMatch(r)) return 2;
    if (RegExp(r'mali-g(77|78|610|710|615|715)\b').hasMatch(r)) return 3;
    final adreno = RegExp(r'adreno.*?(\d{3})').firstMatch(r);
    if (adreno != null) {
      final n = int.parse(adreno.group(1)!);
      if (n < 400) return 0;
      if (n < 600) return n >= 530 ? 2 : 1;
      return 3;
    }
    if (r.contains('nvidia') || r.contains('tegra')) return 3;
    return null;
  }

  AxisScore scoreRam(HardwareProfile p) {
    final total = p.totalRamBytes;
    if (total == null) {
      return const AxisScore('RAM', null, 'Total RAM not reported');
    }
    final gb = total / (1024 * 1024 * 1024);
    // Thresholds sit below marketing sizes because the OS reserves memory
    // (a "2 GB" box typically reports ~1.8 GB).
    final score = gb < 1.4 ? 0 : gb < 2.5 ? 1 : gb < 4.5 ? 2 : 3;
    return AxisScore('RAM', score, '${gb.toStringAsFixed(1)} GB total');
  }

  DeviceClassification classify(HardwareProfile p) {
    final cpu = scoreCpu(p), gpu = scoreGpu(p), ram = scoreRam(p);
    final caps = <String>[];
    final known = [cpu.score, gpu.score].whereType<int>().toList();

    int tier;
    String confidence;
    if (known.isEmpty) {
      tier = 0;
      confidence = 'low';
      caps.add('CPU and GPU could not be identified; assuming ENTRY.');
    } else {
      // The weakest of CPU/GPU limits emulation performance.
      tier = known.reduce((a, b) => a < b ? a : b);
      confidence = known.length == 2 && ram.score != null ? 'high' : 'medium';
    }

    if (ram.score != null) {
      final ramCap = switch (ram.score!) { 0 => 0, 1 => 2, _ => 3 };
      if (tier > ramCap) {
        tier = ramCap;
        caps.add('RAM (${ram.reason}) limits the tier.');
      }
    }
    if (!p.supportsArm64 && tier > 2) {
      tier = 2;
      caps.add('No 64-bit (arm64-v8a) userspace: GameCube/Wii/PS2 emulators '
          'are arm64-only.');
    }
    if (p.is32BitUserspaceOn64BitCpu) {
      caps.add('64-bit CPU running a 32-bit Android build.');
    }
    final es = p.glEsVersionNumber;
    if (es != null && es < 3.0 && tier > 1) {
      tier = 1;
      caps.add('OpenGL ES $es limits 3D emulators.');
    }

    return DeviceClassification(
      tier: _tiers[tier.clamp(0, 3)],
      axes: [cpu, gpu, ram],
      caps: caps,
      confidence: confidence,
    );
  }

  /// Estimates how well [console] should run with [emulator] (optional) on a
  /// device. Pure hardware estimate; replaced by test evidence when available.
  CompatibilityEstimate estimate(
    HardwareProfile p,
    DeviceClassification c,
    ConsoleDefinition console, {
    KnownEmulator? emulator,
  }) {
    final reasons = <String>[];
    final needsArm64 =
        console.requiresArm64 || (emulator?.requiresArm64 ?? false);
    if (needsArm64 && !p.supportsArm64) {
      if (p.supportedAbis.isEmpty) {
        return const CompatibilityEstimate(
          rating: CompatibilityRating.notTested,
          evidence: EvidenceLevel.hardwareEstimate,
          reasons: ['CPU ABIs unknown'],
        );
      }
      return const CompatibilityEstimate(
        rating: CompatibilityRating.unsupported,
        evidence: EvidenceLevel.hardwareEstimate,
        reasons: ['Requires a 64-bit (arm64-v8a) Android build'],
      );
    }
    final minEs = [console.minGlEs, emulator?.minGlEs ?? 0]
        .reduce((a, b) => a > b ? a : b);
    final es = p.glEsVersionNumber;
    if (es != null && es < minEs) {
      return CompatibilityEstimate(
        rating: CompatibilityRating.unsupported,
        evidence: EvidenceLevel.hardwareEstimate,
        reasons: ['Requires OpenGL ES $minEs (device reports $es)'],
      );
    }
    final minSdk = emulator?.minSdk;
    if (minSdk != null && p.sdkInt != null && p.sdkInt! < minSdk) {
      return CompatibilityEstimate(
        rating: CompatibilityRating.unsupported,
        evidence: EvidenceLevel.hardwareEstimate,
        reasons: ['Emulator requires Android API $minSdk'],
      );
    }
    if (c.confidence == 'low') {
      return const CompatibilityEstimate(
        rating: CompatibilityRating.notTested,
        evidence: EvidenceLevel.hardwareEstimate,
        reasons: ['Not enough hardware information to estimate'],
      );
    }

    final t = c.tier.index;
    CompatibilityRating rating;
    if (t < console.minTier.index) {
      rating = CompatibilityRating.limited;
      reasons.add('Device tier is below the estimated minimum '
          '(${console.minTier.label}).');
    } else if (t < console.recommendedTier.index) {
      rating = CompatibilityRating.good;
      reasons.add('Meets the estimated minimum; below recommended '
          '(${console.recommendedTier.label}).');
    } else {
      rating = CompatibilityRating.excellent;
      reasons.add('Meets the estimated recommended tier.');
    }
    reasons.add('Not yet confirmed by a benchmark or test result.');
    return CompatibilityEstimate(
      rating: rating,
      evidence: EvidenceLevel.hardwareEstimate,
      reasons: reasons,
    );
  }
}
