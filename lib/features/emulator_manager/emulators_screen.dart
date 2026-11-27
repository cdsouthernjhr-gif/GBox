import 'package:flutter/material.dart';

import '../../core/constants/console_catalog.dart';
import '../../core/services/system_services.dart';
import '../../domain/entities/performance_tier.dart';
import '../../shared/widgets/tv_widgets.dart';
import 'launch_dialogs.dart';
import 'custom_emulator_screen.dart';
import '../../data/repositories/settings_repository.dart';
import '../../integrations/emulator_adapters/custom_emulator.dart';
import '../game_library/library_screens.dart' show consoleColor;
import '../console_manager/consoles_screen.dart';
import '../settings/settings_screen.dart' show PlayerCoresScreen;
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
      subtitle: 'The built-in emulators and the emulator apps on this device',
      actions: [
        TvButton(
          label: 'Add emulator',
          icon: Icons.add_rounded,
          primary: true,
          onPressed: () =>
              Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const CustomEmulatorScreen())),
        ),
        TvButton(
          label: 'Built-in settings',
          icon: Icons.tune_rounded,
          onPressed: () =>
              Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const PlayerCoresScreen())),
        ),
        TvButton(
          label: 'Consoles',
          icon: Icons.videogame_asset_rounded,
          onPressed: () => SubPage.open(context, const ConsolesScreen()),
        ),
        TvButton(label: 'Rescan', icon: Icons.refresh_rounded, onPressed: () => s.emulators.detect()),
      ],
      child: ValueListenableBuilder<List<EmulatorInstallation>?>(
        valueListenable: s.emulators.installations,
        builder: (context, list, _) {
          if (list == null) return const Center(child: CircularProgressIndicator());
          final sorted = [...list]..sort((a, b) => (b.isInstalled ? 1 : 0) - (a.isInstalled ? 1 : 0));
          return ValueListenableBuilder<SettingsState>(
            valueListenable: s.settings.state,
            builder: (context, st, _) {
              final custom = st.customEmulators;
              return ListView.separated(
                itemCount: sorted.length + 1 + (custom.isEmpty ? 0 : custom.length + 2),
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  // "Added by you" first, then the emulators GAMEBOX knows.
                  if (custom.isNotEmpty) {
                    if (i == 0) return const SectionHeader('Added by you');
                    if (i <= custom.length) return _CustomTile(custom[i - 1]);
                    if (i == custom.length + 1) return const SectionHeader('Emulators GAMEBOX knows');
                    i -= custom.length + 2;
                  }
                  if (i == sorted.length) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Install emulators from their official sources (e.g. the developer website or '
                        'your app store). All listed emulators can launch games from GAMEBOX; RetroArch covers '
                        'most systems through cores installed inside RetroArch. Launch methods are experimental '
                        'until verified on a TV box. BIOS files are never provided by GAMEBOX.',
                        style: TextStyle(color: Colors.white60),
                      ),
                    );
                  }
                  return _EmulatorTile(sorted[i]);
                },
              );
            },
          );
        },
      ),
    );
  }
}

/// An emulator the user added: select to edit or remove it.
class _CustomTile extends StatelessWidget {
  const _CustomTile(this.e);
  final CustomEmulator e;

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    final t = Theme.of(context).textTheme;
    return TvFocusable(
      scale: 1.01,
      padding: const EdgeInsets.all(14),
      onSelect: () =>
          Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => CustomEmulatorScreen(existing: e))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<Map<String, String?>>(
            future: s.gateway.installedVersions([e.packageName]),
            builder: (context, snap) {
              final installed = snap.data?.containsKey(e.packageName) ?? false;
              return Icon(Icons.extension_rounded, size: 34, color: installed ? Colors.greenAccent : Colors.white38);
            },
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(e.name, style: t.titleLarge),
                    ),
                    FutureBuilder<Map<String, String?>>(
                      future: s.gateway.installedVersions([e.packageName]),
                      builder: (context, snap) {
                        if (!snap.hasData) return const SizedBox.shrink();
                        final v = snap.data![e.packageName];
                        return snap.data!.containsKey(e.packageName)
                            ? StatusChip('Installed ${v ?? ''}'.trim(), color: Colors.greenAccent)
                            : const StatusChip('Not installed', color: Colors.orangeAccent);
                      },
                    ),
                    const StatusChip('Added by you', color: Colors.white54),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${e.packageName} · ${e.method.label}', style: t.bodySmall?.copyWith(color: Colors.white60)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final c in e.consoleIds) StatusChip(consoleById(c)?.name ?? c, color: consoleColor(c)),
                  ],
                ),
                Text('Select to edit or remove', style: t.bodySmall?.copyWith(color: Colors.white38)),
              ],
            ),
          ),
        ],
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
      // The built-in player is GAMEBOX itself: nothing to open.
      onSelect: inst.isInstalled && e.id != builtInPlayerId
          ? () async {
              final ok = await s.gateway.launchApp(inst.installedPackage!);
              if (!ok && context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Android could not open ${e.name}.')));
              }
            }
          : (inst.isInstalled
                ? null
                : () => showGetEmulatorDialog(context, e.consoleIds.first, [e.id], title: 'Get ${e.name}')),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.memory_rounded, size: 34, color: inst.isInstalled ? Colors.greenAccent : Colors.white38),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Wrap, not Row: name + chips exceed a 1080p tile width.
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(e.name, style: t.titleLarge),
                    ),
                    StatusChip(
                      inst.isInstalled ? 'Installed ${inst.version ?? ''}'.trim() : 'Not installed',
                      color: inst.isInstalled ? Colors.greenAccent : Colors.white54,
                    ),
                    StatusChip(e.strategy.name, color: Colors.white54),
                    if (launcherFor(e.id) != null)
                      const StatusChip('Launches games (experimental)', color: Colors.orangeAccent)
                    else
                      const StatusChip('Open only', color: Colors.white38),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Licence: ${e.license}${e.requiresArm64 ? ' · 64-bit Android only' : ''}'
                  '${inst.isInstalled ? ' · Select to open' : ''}',
                  style: t.bodySmall?.copyWith(color: Colors.white60),
                ),
                if (e.notes != null) Text(e.notes!, style: t.bodySmall?.copyWith(color: Colors.white60)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final c in consoles)
                      () {
                        final est = (dev.profile != null && dev.classification != null)
                            ? s.device.classifier.estimate(dev.profile!, dev.classification!, c, emulator: e)
                            : null;
                        return StatusChip(
                          '${c.name}: ${est?.rating.label ?? 'Not Tested'}',
                          color: est == null ? Colors.white54 : ratingColor(context, est.rating),
                        );
                      }(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
