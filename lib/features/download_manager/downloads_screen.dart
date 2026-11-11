import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/utilities/formatters.dart';
import '../../shared/widgets/tv_widgets.dart';

/// Download dashboard backed by the persistent `download_queue` table.
/// The transfer engine (HTTPS validation, resume, hash checks) is Phase 5.
class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = servicesOf(context).db;
    return PageFrame(
      title: 'Downloads',
      subtitle: 'Authorised downloads only — never executed automatically',
      child: StreamBuilder<List<DownloadQueueRow>>(
        stream: db.watchDownloadQueue(),
        builder: (context, snap) {
          final items = snap.data ?? const [];
          if (items.isEmpty) {
            return const EmptyState(
              icon: Icons.download_outlined,
              title: 'No downloads',
              message: 'The Online Source Manager and download engine arrive in Phase 5. '
                  'Only legally authorised sources (homebrew, public domain, your own files) '
                  'will be supported.',
            );
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final d = items[i];
              final progress = (d.totalBytes ?? 0) > 0 ? d.downloadedBytes / d.totalBytes! : null;
              return TvFocusable(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(d.name, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(value: progress),
                  const SizedBox(height: 4),
                  Text('${d.status.toUpperCase()} · ${formatBytes(d.downloadedBytes)} / '
                      '${formatBytes(d.totalBytes)} · ${d.destination}'
                      '${d.errorMessage != null ? ' · ${d.errorMessage}' : ''}',
                      style: const TextStyle(color: Colors.white60, fontSize: 12)),
                ]),
              );
            },
          );
        },
      ),
    );
  }
}
