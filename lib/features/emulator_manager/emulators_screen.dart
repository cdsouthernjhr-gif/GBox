import 'package:flutter/material.dart';

import '../../core/constants/console_catalog.dart';
import '../../core/services/system_services.dart';
import '../../domain/entities/performance_tier.dart';
import '../../shared/widgets/tv_widgets.dart';
import '../../integrations/emulator_adapters/launcher_registry.dart';
import '../game_library/game_detail_screen.dart' show ratingColor;

/// Lists supported external emulator apps and whether they are installed.
/// GAMEBOX does not bundle or download emulators.
class EmulatorsScreen extends StatelessWidget {
  const EmulatorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    return PageFrame(
      title: 'Emulators',
      subtitle: 'Installed emulator apps detected on this device',
      actions: [
        TvButton(label: 'Rescan', icon: Icons.refresh_rounded, onPressed: () => s.emulators.detect()),
      ],
      child: ValueListenableBuilder<List<EmulatorInstallation>?>(
        valueListenable: s.emulators.installations,
        builder: (context, list, _) {
          if (list == null) return const Center(child: CircularProgressIndicator());
          final sorted = [...list]..sort((a, b) => (b.isInstalled ? 1 : 0) - (a.isInstalled ? 1 : 0));
          return ListView.separated(
            itemCount: sorted.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              if (i == sorted.length) {
                return const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Install emulators from their official sources (e.g. the developer website or '
                    'your app store). Phase 3: RetroArch (NES, SNES, Master System, Mega Drive, Game Boy, '
                    'GBA, PS1) and DuckStation (PS1) can launch games. These launch methods are '
                    'experimental until verified on a TV box. Other emulators follow in Phase 6.',
                    style: TextStyle(color: Colors.white60),
                  ),
                );
              }
              return _EmulatorTile(sorted[i]);
            },
          );
        },
      ),
    );
  }
}

class _EmulatorTile extends StatelessWidget {
  const _EmulatorTile(this.inst);
  final EmulatorInstallation inst;

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    final t = Theme.of(context).textTheme;
    final e = inst.emulator;
    final dev = s.device.state.value;
    final consoles = e.consoleIds.map(consoleById).whereType<ConsoleDefinition>().toList();

    return TvFocusable(
      scale: 1.01,
      padding: const EdgeInsets.all(14),
      onSelect: inst.isInstalled
          ? () async {
              final ok = await s.gateway.launchApp(inst.installedPackage!);
              if (!ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Android could not open ${e.name}.')));
              }
            }
          : null,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.memory_rounded, size: 34, color: inst.isInstalled ? Colors.greenAccent : Colors.white38),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Wrap, not Row: name + chips exceed a 1080p tile width.
            Wrap(spacing: 6, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
              Padding(padding: const EdgeInsets.only(right: 4), child: Text(e.name, style: t.titleLarge)),
              StatusChip(inst.isInstalled ? 'Installed ${inst.version ?? ''}'.trim() : 'Not installed',
                  color: inst.isInstalled ? Colors.greenAccent : Colors.white54),
              StatusChip(e.strategy.name, color: Colors.white54),
              if (launcherFor(e.id) != null)
                const StatusChip('Launches games (experimental)', color: Colors.orangeAccent)
              else
                const StatusChip('Open only', color: Colors.white38),
            ]),
            const SizedBox(height: 4),
            Text('Licence: ${e.license}${e.requiresArm64 ? ' · 64-bit Android only' : ''}'
                '${inst.isInstalled ? ' · Select to open' : ''}',
                style: t.bodySmall?.copyWith(color: Colors.white60)),
            if (e.notes != null)
              Text(e.notes!, style: t.bodySmall?.copyWith(color: Colors.white60)),
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final c in consoles)
                () {
                  final est = (dev.profile != null && dev.classification != null)
                      ? s.device.classifier.estimate(dev.profile!, dev.classification!, c, emulator: e)
                      : null;
                  return StatusChip('${c.name}: ${est?.rating.label ?? 'Not Tested'}',
                      color: est == null ? Colors.white54 : ratingColor(context, est.rating));
                }(),
            ]),
          ]),
        ),
      ]),
    );
  }
}
