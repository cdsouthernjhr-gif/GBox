import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/services/platform_gateway.dart';
import '../../shared/widgets/tv_widgets.dart';

/// Installed Android apps, so GAMEBOX as HOME never locks the user out.
class AppsScreen extends StatefulWidget {
  const AppsScreen({super.key});

  @override
  State<AppsScreen> createState() => _AppsScreenState();
}

class _AppsScreenState extends State<AppsScreen> {
  late Future<List<InstalledApp>> _apps;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _apps = servicesOf(context).gateway.listApps();
  }

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    return PageFrame(
      title: 'Android apps',
      subtitle: 'Select to open · long-press for app info',
      actions: [
        TvButton(
          label: 'Android Settings',
          icon: Icons.settings_applications_rounded,
          onPressed: () => s.gateway.openAndroidSettings(),
        ),
      ],
      child: FutureBuilder<List<InstalledApp>>(
        future: _apps,
        builder: (context, snap) {
          if (snap.hasError) {
            return EmptyState(icon: Icons.error_outline, title: 'Could not list apps', message: '${snap.error}');
          }
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final apps = snap.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(6),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 150,
              mainAxisExtent: 128,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: apps.length,
            itemBuilder: (context, i) => _AppTile(apps[i]),
          );
        },
      ),
    );
  }
}

class _AppTile extends StatefulWidget {
  const _AppTile(this.app);
  final InstalledApp app;

  @override
  State<_AppTile> createState() => _AppTileState();
}

class _AppTileState extends State<_AppTile> {
  // Small per-process icon cache; icons are 128 px PNGs (~10-20 KB each).
  static final Map<String, Uint8List?> _cache = {};
  Uint8List? _icon;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final pkg = widget.app.packageName;
    if (_cache.containsKey(pkg)) {
      _icon = _cache[pkg];
    } else {
      servicesOf(context).gateway.appImage(pkg).then((bytes) {
        _cache[pkg] = bytes;
        if (mounted) setState(() => _icon = bytes);
      }).catchError((Object _) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    return TvFocusable(
      semanticLabel: widget.app.label,
      onSelect: () async {
        final ok = await s.gateway.launchApp(widget.app.packageName);
        if (!ok && context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Could not open ${widget.app.label}')));
        }
      },
      onLongPress: () => s.gateway.openAppDetails(widget.app.packageName),
      padding: const EdgeInsets.all(10),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
          width: 56,
          height: 56,
          child: _icon == null
              ? const Icon(Icons.android_rounded, size: 44, color: Colors.white38)
              : Image.memory(_icon!, cacheWidth: 112, gaplessPlayback: true),
        ),
        const SizedBox(height: 8),
        Text(widget.app.label,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
