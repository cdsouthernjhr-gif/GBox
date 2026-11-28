/// HOME's quick actions and status (GAMEBOX 1.0): every tile opens the
/// screen it describes. Values the device doesn't report are left out or
/// shown as UNKNOWN, never guessed.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/device/device_intelligence_service.dart';
import '../../core/services/platform_gateway.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utilities/formatters.dart';
import '../../domain/entities/hardware_profile.dart';
import '../../domain/entities/performance_tier.dart';
import '../../shared/widgets/tv_widgets.dart';
import '../compatibility/device_report_screen.dart';
import '../controller_manager/controllers_screen.dart';
import '../setup/rom_search_screen.dart';
import '../storage_manager/storage_screen.dart';

/// What HOME can switch to in the side menu.
class HomeNavigation {
  const HomeNavigation({
    required this.addGames,
    required this.emulators,
    required this.settings,
    required this.openMenu,
  });
  final VoidCallback addGames;
  final VoidCallback emulators;
  final VoidCallback settings;
  final VoidCallback openMenu;
}

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key, required this.nav});
  final HomeNavigation nav;

  @override
  Widget build(BuildContext context) {
    final palette = GameboxPalette.of(context);
    final actions = <(IconData, String, String, Color, VoidCallback)>[
      (Icons.add_circle_outline_rounded, 'Add games', 'Find, import, download', palette.play, nav.addGames),
      (
        Icons.manage_search_rounded,
        'Find ROMs',
        'Search this device',
        palette.focus,
        () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const RomSearchScreen())),
      ),
      (Icons.memory_rounded, 'Emulators', 'Built-in and apps', palette.accent, nav.emulators),
      (
        Icons.gamepad_rounded,
        'Controllers',
        'Map, test, calibrate',
        palette.focus,
        () => SubPage.open(context, const ControllersScreen()),
      ),
      (Icons.settings_rounded, 'Settings', 'Themes, storage, system', palette.accent, nav.settings),
    ];
    return HomeTileRow(
      title: 'Quick actions',
      rowKey: 'row-quick',
      tiles: [
        for (final (i, (icon, title, subtitle, color, onSelect)) in actions.indexed)
          HomeTile(
            icon: icon,
            title: title,
            lines: [subtitle],
            color: color,
            firstInRow: i == 0,
            onOpenMenu: nav.openMenu,
            onSelect: onSelect,
          ),
      ],
    );
  }
}

class StatusRow extends StatelessWidget {
  const StatusRow({super.key, required this.nav});
  final HomeNavigation nav;

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    final palette = GameboxPalette.of(context);
    return HomeTileRow(
      title: 'Status',
      rowKey: 'row-status',
      tiles: [
        ValueListenableBuilder<List<InputDeviceInfo>>(
          valueListenable: s.controllers.devices,
          builder: (context, list, _) {
            final pads = list.where((d) => d.isGameController).toList();
            return HomeTile(
              key: const ValueKey('status-controllers'),
              icon: Icons.gamepad_rounded,
              title: pads.isEmpty ? 'No controller' : '${pads.length} controller${pads.length == 1 ? '' : 's'}',
              lines: [pads.isEmpty ? 'Connect one by Bluetooth or USB' : pads.first.name],
              color: pads.isEmpty ? Colors.white54 : palette.success,
              firstInRow: true,
              onOpenMenu: nav.openMenu,
              onSelect: () => SubPage.open(context, const ControllersScreen()),
            );
          },
        ),
        ValueListenableBuilder<List<StorageVolumeInfo>>(
          valueListenable: s.storage.volumes,
          builder: (context, vols, _) {
            final primary = vols.where((v) => v.isPrimary).firstOrNull ?? vols.firstOrNull;
            final removable = vols.where((v) => v.isRemovable).length;
            final free = primary?.availableBytes;
            final total = primary?.totalBytes;
            return HomeTile(
              key: const ValueKey('status-storage'),
              icon: Icons.sd_storage_rounded,
              title: free == null ? 'Storage' : '${formatBytes(free)} free',
              lines: [
                total == null ? 'Size UNKNOWN' : 'of ${formatBytes(total)}',
                if (removable > 0) '$removable USB/SD connected',
              ],
              color: free != null && total != null && total > 0 && free / total < 0.1 ? palette.warning : palette.focus,
              firstInRow: false,
              onOpenMenu: nav.openMenu,
              onSelect: () => SubPage.open(context, const StorageScreen()),
            );
          },
        ),
        ValueListenableBuilder<DeviceState>(
          valueListenable: s.device.state,
          builder: (context, st, _) {
            final p = st.profile;
            return ValueListenableBuilder<ConnectivityStatus>(
              valueListenable: s.connectivity.status,
              builder: (context, net, _) => HomeTile(
                key: const ValueKey('status-system'),
                icon: Icons.speed_rounded,
                title: st.classification?.tier.label ?? (st.scanning ? 'Scanning…' : 'System'),
                lines: [
                  'Android ${p?.androidVersion ?? 'UNKNOWN'}'
                      '${p?.totalRamBytes != null ? ' · ${formatBytes(p!.totalRamBytes)} RAM' : ''}',
                  net.isOnline ? 'Online' : (net.connected ? 'No internet' : 'Offline'),
                ],
                color: palette.accent,
                firstInRow: false,
                onOpenMenu: nav.openMenu,
                onSelect: () =>
                    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const DeviceReportScreen())),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// A titled horizontal row of [HomeTile]s.
class HomeTileRow extends StatelessWidget {
  const HomeTileRow({super.key, required this.title, required this.rowKey, required this.tiles});
  final String title;
  final String rowKey;
  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) => Padding(
    key: ValueKey(rowKey),
    padding: const EdgeInsets.only(top: 6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: GameboxPalette.of(context).accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ],
        ),
        SizedBox(
          height: 104,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            itemCount: tiles.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (_, i) => tiles[i],
          ),
        ),
      ],
    ),
  );
}

class HomeTile extends StatelessWidget {
  const HomeTile({
    super.key,
    required this.icon,
    required this.title,
    required this.lines,
    required this.color,
    required this.firstInRow,
    required this.onOpenMenu,
    required this.onSelect,
  });
  final IconData icon;
  final String title;
  final List<String> lines;
  final Color color;
  final bool firstInRow;
  final VoidCallback onOpenMenu;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) => Focus(
    canRequestFocus: false,
    skipTraversal: true,
    onKeyEvent: (node, event) {
      if (event is! KeyDownEvent) return KeyEventResult.ignored;
      if ((event.logicalKey == LogicalKeyboardKey.arrowLeft && firstInRow) ||
          event.logicalKey == LogicalKeyboardKey.gameButtonStart) {
        onOpenMenu();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    },
    child: SizedBox(
      width: 168,
      child: TvFocusable(
        scale: 1.06,
        borderRadius: 10,
        semanticLabel: title,
        color: color.withValues(alpha: 0.18),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        onSelect: onSelect,
        child: Row(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                  for (final l in lines)
                    Text(
                      l,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: Colors.white60),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
