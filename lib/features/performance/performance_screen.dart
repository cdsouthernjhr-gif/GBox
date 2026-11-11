import 'dart:async';
import 'dart:ui' show FramePhase;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utilities/formatters.dart';
import '../../shared/widgets/tv_widgets.dart';
import 'benchmark_service.dart';

/// Performance monitor (spec Part 17) and benchmarks. Shows only what
/// Android lets an app read; anything else is labelled as not accessible.
class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  Timer? _timer;
  Map<String, dynamic>? _snap;
  Map<String, dynamic>? _prev;
  double? _appCpuPct;
  bool _running = false;
  List<BenchmarkResult> _last = const [];
  Future<List<BenchmarkRow>>? _history;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_timer != null) return;
    _poll();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _poll());
    _history = servicesOf(context).benchmarks.history();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _poll() async {
    try {
      final s = await servicesOf(context).gateway.performanceSnapshot();
      if (!mounted) return;
      final p = _prev;
      double? pct;
      if (p != null) {
        final dCpu = ((s['appCpuTimeMs'] as num?) ?? 0) - ((p['appCpuTimeMs'] as num?) ?? 0);
        final dUp = ((s['uptimeMs'] as num?) ?? 0) - ((p['uptimeMs'] as num?) ?? 0);
        final cores = servicesOf(context).device.state.value.profile?.cpuCores ?? 1;
        if (dUp > 0) pct = (dCpu / dUp / cores * 100).clamp(0, 100).toDouble();
      }
      setState(() {
        _prev = s;
        _snap = s;
        _appCpuPct = pct;
      });
    } catch (_) {}
  }

  Future<void> _runBenchmarks() async {
    final s = servicesOf(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _running = true);
    try {
      final results = <BenchmarkResult>[
        await s.benchmarks.cpuSingle(),
        await s.benchmarks.cpuMulti(),
        await s.benchmarks.memory(),
        ...await s.benchmarks.storage('${await s.gameboxRoot()}/Downloads'),
      ];
      if (!mounted) return;
      final ui = await Navigator.of(context).push<BenchmarkResult>(
          MaterialPageRoute(builder: (_) => const FrameBenchmarkScreen()));
      if (ui != null) results.add(ui);
      final saved = await s.benchmarks.save(results);
      setState(() {
        _last = results;
        _history = s.benchmarks.history();
      });
      if (!saved) messenger.showSnackBar(const SnackBar(content: Text('Scan the hardware first to store results.')));
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  String _fmt(BenchmarkResult r) => '${r.score.toStringAsFixed(r.score < 10 ? 2 : 0)} ${r.type.unit}'
      '${r.minimumFps != null ? ' (worst 1 s: ${r.minimumFps!.toStringAsFixed(0)})' : ''}';

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    final palette = GameboxPalette.of(context);
    final snap = _snap;
    final total = (snap?['totalRamBytes'] as num?)?.toInt();
    final avail = (snap?['availableRamBytes'] as num?)?.toInt();
    final zones = ((snap?['thermalZones'] as List?) ?? const []).cast<Map>();
    final freqs = ((snap?['cpuCurFreqKhz'] as List?) ?? const []);
    final thermalStatus = (snap?['thermalStatus'] as num?)?.toInt();
    const statusNames = ['None', 'Light', 'Moderate', 'Severe', 'Critical', 'Emergency', 'Shutdown'];
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: palette.decoration,
        child: SafeArea(
          child: PageFrame(
            title: 'Performance & benchmarks',
            subtitle: 'Live data GAMEBOX is allowed to read · refreshes every 2 s',
            actions: [
              TvButton(
                label: _running ? 'Running…' : 'Run benchmarks',
                primary: true,
                autofocus: true,
                onPressed: _running ? null : _runBenchmarks,
              ),
              TvButton(label: 'Back', onPressed: () => Navigator.pop(context)),
            ],
            child: ListView(children: [
              const SectionHeader('Now'),
              InfoRow('RAM in use',
                  total == null || avail == null ? null : '${formatBytes(total - avail)} of ${formatBytes(total)}'),
              if (total != null && avail != null)
                LinearProgressIndicator(value: (total - avail) / total, minHeight: 8),
              InfoRow('Low-memory state', snap == null ? null : (snap['lowMemory'] == true ? 'YES' : 'No')),
              InfoRow('GAMEBOX CPU use', _appCpuPct == null ? 'measuring…' : '${_appCpuPct!.toStringAsFixed(1)} %'),
              InfoRow('System CPU use',
                  snap?['procStatReadable'] == true ? 'readable (not shown)' : 'Not accessible to apps on Android 8+'),
              InfoRow('CPU core clocks',
                  freqs.isEmpty || freqs.every((f) => f == null)
                      ? null
                      : '${freqs.map((f) => f == null ? '?' : '${((f as num) / 1000).round()}').join(' / ')} MHz'),
              InfoRow('Thermal status (Android)', thermalStatus == null ? null : statusNames[thermalStatus.clamp(0, 6)]),
              if (zones.isEmpty) const InfoRow('Temperatures', null),
              for (final z in zones)
                InfoRow('Temp: ${z['type'] ?? z['zone']}', '${(z['celsius'] as num).toStringAsFixed(1)} °C'),
              InfoRow('Game running',
                  s.launcher.activeSession == null ? 'No' : 'Yes (session ${s.launcher.activeSession})'),
              const SizedBox(height: 16),
              const SectionHeader('Benchmarks',
                  subtitle: 'Measure this box itself. Emulator frame rates cannot be read from other apps.'),
              for (final r in _last) InfoRow(r.type.label, _fmt(r)),
              FutureBuilder<List<BenchmarkRow>>(
                future: _history,
                builder: (context, snap) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if ((snap.data ?? const []).isEmpty)
                    const Text('No benchmark results yet.', style: TextStyle(color: Colors.white54)),
                  for (final b in snap.data ?? const <BenchmarkRow>[])
                    InfoRow(
                      '${formatDateTime(b.ranAt)} · ${BenchmarkType.values.where((t) => t.name == b.benchmarkType).firstOrNull?.label ?? b.benchmarkType}',
                      '${b.score?.toStringAsFixed(1)} ${BenchmarkType.values.where((t) => t.name == b.benchmarkType).firstOrNull?.unit ?? ''}',
                    ),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Renders a moving scene for 5 s and measures real frame timings
/// (FrameTiming from the engine). Pops with the result.
class FrameBenchmarkScreen extends StatefulWidget {
  const FrameBenchmarkScreen({super.key, this.duration = const Duration(seconds: 5)});
  final Duration duration;

  @override
  State<FrameBenchmarkScreen> createState() => _FrameBenchmarkScreenState();
}

class _FrameBenchmarkScreenState extends State<FrameBenchmarkScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _anim =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
  final _frames = <int>[]; // frame end timestamps (µs)
  late final Stopwatch _sw = Stopwatch()..start();
  Timer? _end;

  void _onTimings(List<FrameTiming> timings) {
    for (final t in timings) {
      _frames.add(t.timestampInMicroseconds(FramePhase.rasterFinish));
    }
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
    _end = Timer(widget.duration, _finish);
  }

  void _finish() {
    SchedulerBinding.instance.removeTimingsCallback(_onTimings);
    final ms = _sw.elapsedMilliseconds;
    final avg = _frames.length / (ms / 1000);
    double? worst;
    if (_frames.length > 1) {
      final start = _frames.first;
      final perSecond = <int, int>{};
      for (final f in _frames) {
        perSecond.update((f - start) ~/ 1000000, (v) => v + 1, ifAbsent: () => 1);
      }
      final full = perSecond.entries.where((e) => e.key < (ms ~/ 1000)).map((e) => e.value);
      if (full.isNotEmpty) worst = full.reduce((a, b) => a < b ? a : b).toDouble();
    }
    if (mounted) {
      Navigator.of(context).pop(BenchmarkResult(BenchmarkType.uiFrames, avg, ms,
          averageFps: avg, minimumFps: worst, notes: '${_frames.length} frames'));
    }
  }

  @override
  void dispose() {
    _end?.cancel();
    SchedulerBinding.instance.removeTimingsCallback(_onTimings);
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = GameboxPalette.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E17),
      body: AnimatedBuilder(
        animation: _anim,
        builder: (context, _) => Stack(children: [
          for (var i = 0; i < 40; i++)
            Positioned(
              left: (i * 53 + _anim.value * 400) % (MediaQuery.of(context).size.width - 60),
              top: (i * 37 + _anim.value * 250) % (MediaQuery.of(context).size.height - 60),
              child: Transform.rotate(
                angle: _anim.value * 6.28 + i,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Color.lerp(palette.accent, palette.focus, (i % 10) / 10),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: palette.focus.withValues(alpha: 0.4), blurRadius: 12)],
                  ),
                ),
              ),
            ),
          const Center(
            child: Text('Measuring launcher rendering…', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          ),
        ]),
      ),
    );
  }
}
