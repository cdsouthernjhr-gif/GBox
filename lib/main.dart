import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'app/app_services.dart';
import 'app/gamebox_app.dart';
import 'core/database/app_database.dart';
import 'core/errors/app_logger.dart';
import 'core/services/platform_gateway.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final log = AppLogger.instance;

  // Crash logging: errors are recorded locally and the launcher keeps running.
  FlutterError.onError = (details) {
    log.error('Flutter error', details.exception, details.stack);
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    log.error('Uncaught error', error, stack);
    return true;
  };

  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  try {
    await log.attachFile(await getApplicationSupportDirectory());
  } catch (_) {}
  log.info('GAMEBOX starting');

  runApp(const _Bootstrap());
}

/// Opens the database and services, showing a minimal splash meanwhile.
/// If initialisation fails, a recovery screen offers a retry instead of a
/// blank launcher.
class _Bootstrap extends StatefulWidget {
  const _Bootstrap();

  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  AppServices? _services;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    setState(() => _error = null);
    try {
      final services = AppServices(gateway: MethodChannelGateway(), db: AppDatabase.open());
      await services.initialize();
      if (mounted) setState(() => _services = services);
    } catch (e, s) {
      AppLogger.instance.error('Startup failed', e, s);
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = _services;
    if (services != null) return GameboxApp(services: services);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: const Color(0xFF0B0E17),
        body: Center(
          child: _error == null
              ? const Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('GAMEBOX',
                      style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: 4)),
                  SizedBox(height: 18),
                  SizedBox(width: 160, child: LinearProgressIndicator()),
                ])
              : Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('GAMEBOX could not start', style: TextStyle(fontSize: 22)),
                  const SizedBox(height: 8),
                  Text('$_error', style: const TextStyle(color: Colors.white60)),
                  const SizedBox(height: 16),
                  FilledButton(autofocus: true, onPressed: _start, child: const Text('Retry')),
                  TextButton(
                    onPressed: () => MethodChannelGateway().openAndroidSettings(),
                    child: const Text('Open Android Settings'),
                  ),
                ]),
        ),
      ),
    );
  }
}
