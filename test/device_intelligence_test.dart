import 'package:flutter_test/flutter_test.dart';
import 'package:gamebox/core/constants/console_catalog.dart';
import 'package:gamebox/core/device/cpuinfo_parser.dart';
import 'package:gamebox/core/device/device_intelligence_service.dart';
import 'package:gamebox/core/device/performance_classifier.dart';
import 'package:gamebox/domain/entities/hardware_profile.dart';
import 'package:gamebox/domain/entities/performance_tier.dart';

import 'support/fakes.dart';

const gb = 1024 * 1024 * 1024;

/// Synthetic profiles exercise the classifier logic only. They are NOT
/// measurements of real devices.
HardwareProfile profile({
  List<String> parts = const ['0xd03'],
  int cores = 4,
  int? freqKhz = 1500000,
  String? renderer,
  String? es = '3.2',
  bool? vulkan = false,
  int? ram = 2 * gb,
  bool arm64 = true,
  List<String> features = const ['fp', 'asimd'],
}) =>
    HardwareProfile(
      scannedAt: DateTime(2026),
      supportedAbis: arm64 ? const ['arm64-v8a', 'armeabi-v7a'] : const ['armeabi-v7a', 'armeabi'],
      supported64BitAbis: arm64 ? const ['arm64-v8a'] : const [],
      cpuParts: parts,
      cpuImplementer: parts.isEmpty ? null : '0x41',
      cpuCores: cores,
      cpuMaxFreqKhz: freqKhz,
      cpuFeatures: features,
      glRenderer: renderer,
      glEsVersion: es,
      vulkanSupported: vulkan,
      totalRamBytes: ram,
    );

void main() {
  group('cpuinfo parser', () {
    test('parses ARM64 big.LITTLE format', () {
      final c = parseCpuInfo(sampleArm64CpuInfo);
      expect(c.processorCount, 4);
      expect(c.hardware, 'Amlogic');
      expect(c.implementer, '0x41');
      expect(c.parts, ['0xd03', '0xd09']);
      expect(c.coreDescription, 'Cortex-A53 + Cortex-A73');
      expect(c.features, contains('asimd'));
    });

    test('parses legacy ARMv7 format with model name in "Processor"', () {
      final c = parseCpuInfo(sampleArmv7CpuInfo);
      expect(c.processorCount, 2);
      expect(c.modelName, 'ARMv7 Processor rev 4 (v7l)');
      expect(c.hardware, 'sun50iw9');
      expect(c.parts, ['0xd03']);
    });

    test('empty or missing input yields unknowns, not guesses', () {
      for (final raw in [null, '', '   ']) {
        final c = parseCpuInfo(raw);
        expect(c.processorCount, isNull);
        expect(c.hardware, isNull);
        expect(c.parts, isEmpty);
        expect(c.coreDescription, isNull);
      }
    });

    test('non-ARM implementer does not get ARM core names', () {
      expect(armCoreName('0x51', '0xd03'), isNull);
      expect(armCoreName('0x41', '0xd03'), 'Cortex-A53');
    });
  });

  group('hardware profile', () {
    test('missing and "unknown" values map to null (UI shows UNKNOWN)', () {
      final p = HardwareProfile.fromMap({
        'manufacturer': 'unknown',
        'model': '',
        'glRenderer': null,
        'sdkInt': 25,
      });
      expect(p.manufacturer, isNull);
      expect(p.model, isNull);
      expect(p.glRenderer, isNull);
      expect(p.sdkInt, 25);
      expect(p.supportsArm64, isFalse);
    });

    test('toMap/fromMap round-trip preserves data', () {
      final p = DeviceIntelligenceService.profileFromNative(syntheticNativeScan(),
          now: DateTime(2026, 1, 2));
      final again = HardwareProfile.fromMap(p.toMap());
      expect(again.toMap(), p.toMap());
    });

    test('native scan is merged with parsed cpuinfo', () {
      final p = DeviceIntelligenceService.profileFromNative(syntheticNativeScan());
      expect(p.cpuModel, 'Cortex-A53 + Cortex-A73');
      expect(p.socModel, 'Amlogic');
      expect(p.cpuParts, ['0xd03', '0xd09']);
      expect(p.gameControllers, hasLength(1));
      expect(p.aspectRatioLabel, '16:9');
    });

    test('detects 64-bit CPU running 32-bit Android', () {
      final p = profile(arm64: false, features: const ['neon', 'aes', 'crc32']);
      expect(p.is32BitUserspaceOn64BitCpu, isTrue);
      expect(profile(arm64: true).is32BitUserspaceOn64BitCpu, isFalse);
    });
  });

  group('performance classifier', () {
    const c = PerformanceClassifier();

    test('Cortex-A53 + Mali-450 (GLES 2) is ENTRY', () {
      final r = c.classify(profile(renderer: 'Mali-450 MP', es: '2.0', arm64: false));
      expect(r.tier, PerformanceTier.entry);
    });

    test('Cortex-A55 + Mali-G31 is STANDARD', () {
      final r = c.classify(profile(parts: ['0xd05'], renderer: 'Mali-G31 MP2', ram: 4 * gb));
      expect(r.tier, PerformanceTier.standard);
      expect(r.confidence, 'high');
    });

    test('Cortex-A73 + Mali-G52 + Vulkan is ADVANCED', () {
      final r = c.classify(
          profile(parts: ['0xd03', '0xd09'], renderer: 'Mali-G52', vulkan: true, ram: 4 * gb));
      expect(r.tier, PerformanceTier.advanced);
    });

    test('Cortex-A76 + Mali-G610 with 8 GB is HIGH PERFORMANCE', () {
      final r = c.classify(profile(
          parts: ['0xd05', '0xd0b'], cores: 8, renderer: 'Mali-G610', vulkan: true, ram: 8 * gb));
      expect(r.tier, PerformanceTier.high);
    });

    test('RAM alone never raises the tier', () {
      final r = c.classify(profile(renderer: 'Mali-450', es: '2.0', ram: 16 * gb));
      expect(r.tier, PerformanceTier.entry);
    });

    test('2 GB RAM caps a strong SoC at ADVANCED', () {
      final r = c.classify(profile(
          parts: ['0xd0b'], cores: 8, renderer: 'Mali-G610', vulkan: true, ram: 2 * gb));
      expect(r.tier, PerformanceTier.advanced);
      expect(r.caps.join(), contains('RAM'));
    });

    test('32-bit Android caps at ADVANCED', () {
      final r = c.classify(profile(
          parts: ['0xd0b'], cores: 8, renderer: 'Mali-G610', vulkan: true, ram: 8 * gb, arm64: false));
      expect(r.tier, PerformanceTier.advanced);
    });

    test('unidentifiable hardware is ENTRY with low confidence', () {
      final r = c.classify(HardwareProfile(scannedAt: DateTime(2026)));
      expect(r.tier, PerformanceTier.entry);
      expect(r.confidence, 'low');
    });

    test('unknown core type falls back to core count/frequency', () {
      final s = c.scoreCpu(profile(parts: const [], cores: 8, freqKhz: 2400000));
      expect(s.score, 2);
      expect(s.reason, contains('core type unknown'));
    });

    group('compatibility estimates', () {
      final strong = profile(
          parts: ['0xd0b'], cores: 8, renderer: 'Mali-G610', vulkan: true, ram: 8 * gb);
      final weak32 = profile(renderer: 'Mali-450', es: '2.0', arm64: false);

      test('arm64-only consoles are Unsupported on 32-bit Android', () {
        final e = c.estimate(weak32, c.classify(weak32), consoleById('ps2')!);
        expect(e.rating, CompatibilityRating.unsupported);
      });

      test('GLES 3 requirement makes Dreamcast Unsupported on GLES 2', () {
        final e = c.estimate(weak32, c.classify(weak32), consoleById('dreamcast')!);
        expect(e.rating, CompatibilityRating.unsupported);
      });

      test('NES is Excellent on an entry device', () {
        final e = c.estimate(weak32, c.classify(weak32), consoleById('nes')!);
        expect(e.rating, CompatibilityRating.excellent);
      });

      test('estimates are always labelled as hardware estimates', () {
        for (final console in consoleCatalog) {
          final e = c.estimate(strong, c.classify(strong), console);
          expect(e.evidence, EvidenceLevel.hardwareEstimate);
          expect(e.rating, isNot(CompatibilityRating.unsupported));
        }
      });

      test('no data gives Not Tested', () {
        final empty = HardwareProfile(scannedAt: DateTime(2026), supportedAbis: const ['arm64-v8a'],
            supported64BitAbis: const ['arm64-v8a']);
        final e = c.estimate(empty, c.classify(empty), consoleById('n64')!);
        expect(e.rating, CompatibilityRating.notTested);
      });

      test('emulator arm64 requirement is respected', () {
        final dolphin = knownEmulators.firstWhere((e) => e.id == 'dolphin');
        final e = c.estimate(weak32, c.classify(weak32), consoleById('gamecube')!, emulator: dolphin);
        expect(e.rating, CompatibilityRating.unsupported);
      });
    });
  });

  group('catalogue', () {
    test('console ids are unique and have extensions', () {
      final ids = consoleCatalog.map((c) => c.id).toList();
      expect(ids.toSet().length, ids.length);
      for (final c in consoleCatalog) {
        expect(c.extensions, isNotEmpty, reason: c.id);
        expect(c.minTier.index <= c.recommendedTier.index, isTrue, reason: c.id);
      }
    });

    test('every emulator references known consoles', () {
      for (final e in knownEmulators) {
        for (final id in e.consoleIds) {
          expect(consoleById(id), isNotNull, reason: '${e.id} -> $id');
        }
      }
    });
  });
}
