import 'package:flutter/material.dart';

import '../../core/constants/console_catalog.dart';
import '../../core/device/device_intelligence_service.dart';
import '../../integrations/emulator_adapters/launcher_registry.dart';
import '../../domain/entities/performance_tier.dart';
import '../../shared/widgets/tv_widgets.dart';
import '../game_library/game_detail_screen.dart' show ratingColor;
import '../game_library/library_screens.dart' show consoleColor;

/// Console catalogue with this device's hardware-based compatibility estimate.
class ConsolesScreen extends StatelessWidget {
  const ConsolesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    return PageFrame(
      title: 'Consoles',
      subtitle: 'Ratings are estimates from detected hardware until tested',
      child: ValueListenableBuilder<DeviceState>(
        valueListenable: s.device.state,
        builder: (context, st, _) => StreamBuilder<Map<String, int>>(
          stream: s.db.watchGameCountsByConsole(),
          builder: (context, snap) {
            final counts = snap.data ?? const {};
            return ListView(children: [
              for (final cat in ConsoleCategory.values) ...[
                SectionHeader(cat.label),
                Wrap(spacing: 12, runSpacing: 12, children: [
                  for (final c in consoleCatalog.where((c) => c.category == cat))
                    _ConsoleTile(console: c, games: counts[c.id] ?? 0, state: st),
                ]),
                const SizedBox(height: 14),
              ],
            ]);
          },
        ),
      ),
    );
  }
}

class _ConsoleTile extends StatelessWidget {
  const _ConsoleTile({required this.console, required this.games, required this.state});
  final ConsoleDefinition console;
  final int games;
  final DeviceState state;

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    final t = Theme.of(context).textTheme;
    final p = state.profile, c = state.classification;
    final est = (p != null && c != null) ? s.device.classifier.estimate(p, c, console) : null;
    return SizedBox(
      width: 236,
      child: TvFocusable(
        onSelect: () => _showDetails(context, est?.reasons),
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 10, height: 10,
                decoration: BoxDecoration(color: consoleColor(console.id), shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Expanded(child: Text(console.name, style: t.titleMedium, overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 6),
          Text('${console.manufacturer} · $games games', style: t.bodySmall?.copyWith(color: Colors.white70)),
          const SizedBox(height: 8),
          Row(children: [
            StatusChip(est?.rating.label ?? 'Not Tested',
                color: est == null ? Colors.white54 : ratingColor(context, est.rating)),
            const SizedBox(width: 6),
            if (launchersForConsole(console.id).isEmpty)
              const StatusChip('No launcher yet', color: Colors.white54),
          ]),
        ]),
      ),
    );
  }

  void _showDetails(BuildContext context, List<String>? reasons) {
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(console.name),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            InfoRow('Games folder', 'GAMEBOX/Games/${console.folderName}/'),
            InfoRow('File types', console.extensions.map((e) => '.$e').join('  ')),
            InfoRow('Estimated minimum', console.minTier.label),
            InfoRow('Estimated recommended', console.recommendedTier.label),
            InfoRow('64-bit Android required', console.requiresArm64 ? 'Yes' : 'No'),
            InfoRow('Minimum OpenGL ES', console.minGlEs.toStringAsFixed(1)),
            InfoRow('Can launch with (experimental)',
                launchersForConsole(console.id).map((l) => l.emulator.name).join(', ')),
            InfoRow('Compatible emulator apps',
                knownEmulators.where((e) => e.consoleIds.contains(console.id)).map((e) => e.name).join(', ')),
            if (console.notes != null) InfoRow('Notes', console.notes),
            if (reasons != null) InfoRow('Rating basis', reasons.join(' ')),
          ]),
        ),
        actions: [
          TextButton(autofocus: true, onPressed: () => Navigator.pop(c), child: const Text('Close')),
        ],
      ),
    );
  }
}
