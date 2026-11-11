import 'package:flutter/material.dart';

import '../../core/constants/console_catalog.dart';
import '../../core/services/platform_gateway.dart';
import '../../core/services/system_services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utilities/formatters.dart';
import '../../domain/entities/hardware_profile.dart';
import '../../domain/entities/performance_tier.dart';
import '../../shared/widgets/tv_widgets.dart';
import '../compatibility/device_report_screen.dart';
import '../game_library/game_detail_screen.dart';
import '../game_library/library_screens.dart';
import '../launcher/launcher_shell.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.onNavigate});
  final ValueChanged<LauncherSection> onNavigate;

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
      children: [
        _ContinuePlaying(onNavigate: onNavigate),
        const SizedBox(height: 18),
        _StatusWidgets(onNavigate: onNavigate),
        const SizedBox(height: 18),
        GameCardRow(
          title: 'Recently played',
          stream: s.db.watchRecentlyPlayed(limit: 12),
          emptyMessage: 'No games played yet.',
        ),
        const SizedBox(height: 14),
        GameCardRow(
          title: 'Recently added',
          stream: s.db.watchRecentlyAdded(limit: 12),
          emptyMessage: 'No games added yet. ROM import arrives in Phase 2.',
        ),
        const SizedBox(height: 14),
        GameCardRow(
          title: 'Favourite games',
          stream: s.db.watchFavorites(),
          emptyMessage: 'Mark games as favourites to pin them here.',
        ),
        const SizedBox(height: 14),
        _ConsoleCategories(onNavigate: onNavigate),
      ],
    );
  }
}

class _ContinuePlaying extends StatelessWidget {
  const _ContinuePlaying({required this.onNavigate});
  final ValueChanged<LauncherSection> onNavigate;

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    final t = Theme.of(context).textTheme;
    final palette = GameboxPalette.of(context);
    return StreamBuilder(
      stream: s.db.watchRecentlyPlayed(limit: 1),
      builder: (context, snap) {
        final last = (snap.data?.isNotEmpty ?? false) ? snap.data!.first : null;
        return TvFocusable(
          scale: 1.015,
          onSelect: last == null
              ? () => onNavigate(LauncherSection.myGames)
              : () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => GameDetailScreen(gameId: last.game.id))),
          color: palette.accent.withValues(alpha: 0.22),
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            Icon(last == null ? Icons.sports_esports_rounded : Icons.play_circle_fill_rounded,
                size: 54, color: palette.focus),
            const SizedBox(width: 18),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(last == null ? 'WELCOME TO GAMEBOX' : 'CONTINUE PLAYING',
                    style: t.labelLarge?.copyWith(color: palette.focus)),
                const SizedBox(height: 4),
                Text(last?.game.title ?? 'Your console is ready',
                    style: t.headlineSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  last == null
                      ? 'Everything here works offline. Game import and emulator launching '
                          'are being added phase by phase.'
                      : '${consoleById(last.game.consoleId)?.name ?? ''} · '
                          'Last played ${formatRelative(last.game.lastPlayedAt)}',
                  style: t.bodyMedium?.copyWith(color: Colors.white70),
                ),
              ]),
            ),
          ]),
        );
      },
    );
  }
}

class _StatusWidgets extends StatelessWidget {
  const _StatusWidgets({required this.onNavigate});
  final ValueChanged<LauncherSection> onNavigate;

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    final palette = GameboxPalette.of(context);
    return SizedBox(
      height: 112,
      child: Row(children: [
        Expanded(
          child: ValueListenableBuilder<List<InputDeviceInfo>>(
            valueListenable: s.controllers.devices,
            builder: (_, list, _) {
              final pads = list.where((d) => d.isGameController).toList();
              return _Tile(
                icon: Icons.gamepad_rounded,
                title: 'Controllers',
                value: pads.isEmpty ? 'None connected' : '${pads.length} connected',
                detail: pads.isEmpty ? 'Remote/D-pad navigation active' : pads.first.name,
                color: pads.isEmpty ? Colors.white54 : palette.success,
                onSelect: () => onNavigate(LauncherSection.controllers),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ValueListenableBuilder<List<StorageVolumeInfo>>(
            valueListenable: s.storage.volumes,
            builder: (_, vols, _) {
              final mounted = vols.where((v) => v.isMounted).toList();
              final primary = mounted.where((v) => v.isPrimary).firstOrNull;
              final removable = mounted.where((v) => v.isRemovable).length;
              return _Tile(
                icon: Icons.sd_storage_rounded,
                title: 'Storage',
                value: primary == null
                    ? 'Scanning…'
                    : '${formatBytes(primary.availableBytes)} free',
                detail: removable == 0 ? 'No USB/SD connected' : '$removable removable drive(s)',
                color: palette.focus,
                onSelect: () => onNavigate(LauncherSection.storage),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: s.device.state,
            builder: (_, st, _) => _Tile(
              icon: Icons.developer_board_rounded,
              title: 'Device compatibility',
              value: st.classification?.tier.label ?? (st.scanning ? 'Scanning…' : 'Not scanned'),
              detail: st.profile == null
                  ? 'Hardware profile pending'
                  : '${st.profile!.manufacturer ?? 'UNKNOWN'} ${st.profile!.model ?? ''}',
              color: palette.accent,
              onSelect: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const DeviceReportScreen())),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ValueListenableBuilder<ConnectivityStatus>(
            valueListenable: s.connectivity.status,
            builder: (_, c, _) => _Tile(
              icon: c.isOnline ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
              title: 'Network',
              value: c.isOnline ? 'Online' : 'Offline',
              detail: c.isOnline
                  ? 'Via ${c.transport}'
                  : 'Local games and settings fully available',
              color: c.isOnline ? palette.success : Colors.white54,
              onSelect: () => onNavigate(LauncherSection.settings),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ValueListenableBuilder<List<EmulatorInstallation>?>(
            valueListenable: s.emulators.installations,
            builder: (_, list, _) {
              final n = list?.where((e) => e.isInstalled).length;
              return _Tile(
                icon: Icons.memory_rounded,
                title: 'Emulators',
                value: n == null ? 'Detecting…' : '$n installed',
                detail: 'of ${knownEmulators.length} supported apps',
                color: (n ?? 0) > 0 ? palette.success : Colors.white54,
                onSelect: () => onNavigate(LauncherSection.emulators),
              );
            },
          ),
        ),
      ]),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.value,
    required this.detail,
    required this.color,
    required this.onSelect,
  });
  final IconData icon;
  final String title;
  final String value;
  final String detail;
  final Color color;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return TvFocusable(
      onSelect: onSelect,
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 6),
          Expanded(
            child: Text(title.toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: t.bodySmall?.copyWith(letterSpacing: 1, color: Colors.white70)),
          ),
        ]),
        const Spacer(),
        Text(value, style: t.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(detail,
            style: t.bodySmall?.copyWith(color: Colors.white54),
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}

class _ConsoleCategories extends StatelessWidget {
  const _ConsoleCategories({required this.onNavigate});
  final ValueChanged<LauncherSection> onNavigate;

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionHeader('Console categories'),
      StreamBuilder<Map<String, int>>(
        stream: s.db.watchGameCountsByConsole(),
        builder: (context, snap) {
          final counts = snap.data ?? const {};
          return SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              itemCount: consoleCatalog.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final c = consoleCatalog[i];
                return SizedBox(
                  width: 150,
                  child: TvFocusable(
                    onSelect: () => onNavigate(LauncherSection.consoles),
                    color: consoleColor(c.id).withValues(alpha: 0.28),
                    padding: const EdgeInsets.all(12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(c.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                      const Spacer(),
                      Text('${counts[c.id] ?? 0} games',
                          style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ]),
                  ),
                );
              },
            ),
          );
        },
      ),
    ]);
  }
}
