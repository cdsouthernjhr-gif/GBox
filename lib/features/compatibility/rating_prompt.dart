import 'package:flutter/material.dart';

import '../../core/constants/console_catalog.dart';
import '../../domain/entities/performance_tier.dart';
import '../../shared/widgets/tv_widgets.dart';
import '../game_library/game_detail_screen.dart' show ratingColor;

/// Optional "how did it run?" prompt after returning from a game. The answer
/// is stored as the user's own local result; sharing requires explicit
/// consent and only happens through a manually exported report.
Future<void> askHowItRan(BuildContext context, int gameId, String? emulatorId) async {
  final s = servicesOf(context);
  final game = await s.db.gameById(gameId);
  if (!context.mounted) return;
  var consent = false;
  final picked = await showDialog<CompatibilityRating>(
    context: context,
    builder: (c) => StatefulBuilder(
      builder: (c, setState) => AlertDialog(
        title: Text('How did ${game.title} run?'),
        content: SizedBox(
          width: 520,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              '${consoleById(game.consoleId)?.name ?? game.consoleId}'
              '${emulatorId == null ? '' : ' · ${knownEmulators.where((e) => e.id == emulatorId).firstOrNull?.name ?? emulatorId}'}'
              ' — your answer improves the compatibility rating on this device.',
              style: const TextStyle(fontSize: 12.5, color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final (i, r) in const [
                CompatibilityRating.excellent,
                CompatibilityRating.good,
                CompatibilityRating.limited,
                CompatibilityRating.unsupported,
              ].indexed)
                TvFocusable(
                  autofocus: i == 0,
                  borderRadius: 20,
                  color: ratingColor(context, r).withValues(alpha: 0.25),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  onSelect: () => Navigator.pop(c, r),
                  child: Text(r == CompatibilityRating.unsupported ? 'Did not work' : r.label),
                ),
            ]),
            const SizedBox(height: 10),
            TvFocusable(
              scale: 1.0,
              color: Colors.transparent,
              padding: const EdgeInsets.all(6),
              onSelect: () => setState(() => consent = !consent),
              child: Row(children: [
                Icon(consent ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Include this result in anonymous compatibility reports I export '
                      '(device model and hardware only — no personal data).'),
                ),
              ]),
            ),
          ]),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Skip'))],
      ),
    ),
  );
  if (picked == null) return;
  await s.compatibility.recordResult(
      consoleId: game.consoleId, rating: picked, emulatorId: emulatorId, gameId: gameId, consentToShare: consent);
}
