import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/constants/console_catalog.dart';
import '../../core/database/app_database.dart';
import '../../core/device/device_intelligence_service.dart';
import '../../core/device/performance_classifier.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utilities/formatters.dart';
import '../../domain/entities/hardware_profile.dart';
import '../../domain/entities/performance_tier.dart';
import '../../shared/widgets/tv_widgets.dart';
import '../game_library/game_detail_screen.dart' show ratingColor;

/// Full hardware capability profile + compatibility report. Every value the
/// device did not report is shown as UNKNOWN.
class DeviceReportScreen extends StatelessWidget {
  const DeviceReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    final palette = GameboxPalette.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: palette.background),
        child: SafeArea(
          child: ValueListenableBuilder<DeviceState>(
            valueListenable: s.device.state,
            builder: (context, st, _) => PageFrame(
              title: 'Device compatibility report',
              subtitle: st.profile == null
                  ? 'No scan yet'
                  : 'Scanned ${formatDateTime(st.profile!.scannedAt)}'
                      '${st.scanning ? ' · rescanning…' : ''}',
              actions: [
                TvButton(
                  autofocus: true,
                  label: st.scanning ? 'Scanning…' : 'Rescan hardware',
                  icon: Icons.radar_rounded,
                  onPressed: st.scanning ? null : () => s.device.scan(),
                ),
                TvButton(
                  label: 'Export report',
                  icon: Icons.save_alt_rounded,
                  onPressed: st.profile == null ? null : () => _export(context, st),
                ),
              ],
              child: st.profile == null
                  ? EmptyState(
                      icon: Icons.developer_board_off_rounded,
                      title: st.scanning ? 'Scanning hardware…' : 'No hardware profile',
                      message: st.error ?? 'Select "Rescan hardware".',
                    )
                  : _Report(profile: st.profile!, c: st.classification!),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _export(BuildContext context, DeviceState st) async {
    final messenger = ScaffoldMessenger.of(context);
    final classifier = servicesOf(context).device.classifier;
    try {
      // App-specific external dir: reachable over USB/file managers, no
      // storage permission needed.
      final base = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
      final dir = Directory('${base.path}/reports');
      await dir.create(recursive: true);
      final stamp = st.profile!.scannedAt.toIso8601String().replaceAll(':', '-').split('.').first;
      final file = File('${dir.path}/gamebox_device_report_$stamp.json');
      final report = {
        'generatedBy': 'GAMEBOX',
        'note': 'Compatibility ratings are hardware estimates unless stated otherwise.',
        'profile': st.profile!.toMap(),
        'tier': st.classification!.tier.name,
        'confidence': st.classification!.confidence,
        'axes': [
          for (final a in st.classification!.axes) {'axis': a.name, 'score': a.score, 'reason': a.reason},
        ],
        'limits': st.classification!.caps,
        'consoles': [
          for (final c in consoleCatalog)
            () {
              final e = classifier.estimate(st.profile!, st.classification!, c);
              return {'console': c.id, 'rating': e.rating.name, 'evidence': e.evidence.name, 'reasons': e.reasons};
            }(),
        ],
      };
      await file.writeAsString(const JsonEncoder.withIndent('  ').convert(report));
      messenger.showSnackBar(SnackBar(content: Text('Report saved: ${file.path}'), duration: const Duration(seconds: 6)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }
}

class _Report extends StatelessWidget {
  const _Report({required this.profile, required this.c});
  final HardwareProfile profile;
  final DeviceClassification c;

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    final p = profile;
    final palette = GameboxPalette.of(context);
    final t = Theme.of(context).textTheme;
    final ramPct = (p.totalRamBytes != null && p.availableRamBytes != null && p.totalRamBytes! > 0)
        ? (p.availableRamBytes! / p.totalRamBytes! * 100).round()
        : null;

    Widget card(String title, List<Widget> rows) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TvFocusable(
            scale: 1.005,
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title.toUpperCase(), style: t.labelLarge?.copyWith(color: palette.focus)),
              const SizedBox(height: 6),
              ...rows,
            ]),
          ),
        );

    return ListView(children: [
      card('Performance category', [
        Row(children: [
          StatusChip(c.tier.label, color: palette.focus),
          const SizedBox(width: 8),
          StatusChip('Confidence: ${c.confidence}', color: Colors.white60),
        ]),
        const SizedBox(height: 6),
        Text(c.tier.description, style: t.bodyMedium),
        for (final a in c.axes)
          InfoRow('${a.name} score', a.score == null ? null : '${a.score}/3 — ${a.reason}'),
        for (final cap in c.caps) Text('• $cap', style: t.bodySmall?.copyWith(color: palette.warning)),
        Text('Ratings use detected hardware only; no FPS is promised until a benchmark is run.',
            style: t.bodySmall?.copyWith(color: Colors.white54)),
      ]),
      card('Device', [
        InfoRow('Manufacturer', p.manufacturer),
        InfoRow('Brand', p.brand),
        InfoRow('Model', p.model),
        InfoRow('Device / product', p.device == null ? null : '${p.device} / ${p.product ?? 'UNKNOWN'}'),
        InfoRow('Android version', p.androidVersion == null ? null : '${p.androidVersion} (API ${p.sdkInt})'),
        InfoRow('Build ID', p.buildId),
        InfoRow('Build fingerprint', p.buildFingerprint),
        InfoRow('Television UI mode', p.isTelevision == null ? null : (p.isTelevision! ? 'Yes' : 'No')),
      ]),
      card('CPU', [
        InfoRow('SoC / hardware', p.socModel ?? p.hardware),
        InfoRow('CPU', p.cpuModel),
        InfoRow('Cores', p.cpuCores),
        InfoRow('Max frequency', p.cpuMaxFreqKhz == null ? null : '${(p.cpuMaxFreqKhz! / 1000).round()} MHz'),
        InfoRow('ABIs', p.supportedAbis.isEmpty ? null : p.supportedAbis.join(', ')),
        InfoRow('ARMv7 (32-bit)', p.supportedAbis.isEmpty ? null : (p.supportsArmV7 ? 'Supported' : 'No')),
        InfoRow('ARM64 (64-bit)', p.supportedAbis.isEmpty ? null : (p.supportsArm64 ? 'Supported' : 'No')),
        if (p.is32BitUserspaceOn64BitCpu)
          Text('64-bit capable CPU running a 32-bit Android build.', style: TextStyle(color: palette.warning)),
      ]),
      card('Memory', [
        InfoRow('Total RAM', formatBytes(p.totalRamBytes)),
        InfoRow('Available RAM', p.availableRamBytes == null ? null : '${formatBytes(p.availableRamBytes)} (${ramPct ?? '?'}%)'),
        InfoRow('Memory pressure', p.lowMemory == null ? null : (p.lowMemory! ? 'LOW MEMORY' : 'Normal')),
        InfoRow('Low-RAM device flag', p.isLowRamDevice),
        InfoRow('App heap class', p.memoryClassMb == null ? null : '${p.memoryClassMb} MB (large: ${p.largeMemoryClassMb} MB)'),
      ]),
      card('GPU', [
        InfoRow('Vendor', p.glVendor),
        InfoRow('Renderer', p.glRenderer),
        InfoRow('OpenGL ES (declared)', p.glEsVersion),
        InfoRow('GL version string', p.glVersion),
        InfoRow('Vulkan', p.vulkanSupported == null
            ? null
            : p.vulkanSupported! ? 'Yes ${p.vulkanApiVersion ?? ''} (level ${p.vulkanHardwareLevel ?? '?'})' : 'Not available'),
      ]),
      card('Display', [
        InfoRow('Resolution', p.displayWidth == null ? null : '${p.displayWidth} × ${p.displayHeight}'),
        InfoRow('Aspect ratio', p.aspectRatioLabel),
        InfoRow('Refresh rate', p.refreshRate == null ? null : '${p.refreshRate!.toStringAsFixed(1)} Hz'),
        InfoRow('Density', p.densityDpi == null ? null : '${p.densityDpi} dpi'),
      ]),
      card('Storage', [
        for (final v in p.storageVolumes)
          InfoRow(v.description, '${v.state} · ${formatBytes(v.availableBytes)} free / ${formatBytes(v.totalBytes)}'),
        if (p.storageVolumes.isEmpty) const InfoRow('Volumes', null),
      ]),
      card('Input devices', [
        for (final d in p.inputDevices) InfoRow(d.name, '${d.classes.join(', ')} · ${d.vendorProductLabel}'),
        if (p.inputDevices.isEmpty) const InfoRow('Devices', null),
      ]),
      card('Console compatibility (hardware estimate)', [
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final console in consoleCatalog)
            () {
              final e = s.device.classifier.estimate(p, c, console);
              return StatusChip('${console.name}: ${e.rating.label}', color: ratingColor(context, e.rating));
            }(),
        ]),
      ]),
      FutureBuilder<List<DeviceCompatibilityRow>>(
        future: s.db.compatibilityHistory(limit: 10),
        builder: (context, snap) => card('Local compatibility history', [
          if ((snap.data ?? const []).isEmpty) const Text('No history yet.'),
          for (final r in snap.data ?? const <DeviceCompatibilityRow>[])
            InfoRow(formatDateTime(r.compatibilityDate), '[${r.source}] ${r.testResult ?? ''} · ${r.gpu ?? 'GPU UNKNOWN'}'),
        ]),
      ),
    ]);
  }
}
