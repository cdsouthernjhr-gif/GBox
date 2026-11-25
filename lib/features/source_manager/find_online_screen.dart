import 'package:flutter/material.dart';

import '../../core/constants/emulator_links.dart';
import '../../shared/widgets/tv_widgets.dart';
import '../setup/rom_search_screen.dart';

/// Search URL opened in the device's browser for [query]. GAMEBOX only opens
/// the browser with what the user typed; it doesn't fetch, list or rank
/// websites itself.
String webSearchUrl(String query) => 'https://www.google.com/search?q=${Uri.encodeQueryComponent(query.trim())}';

/// Find games online: a web search that opens the device's browser, legal
/// homebrew sources, and a reminder that downloaded files are picked up by
/// "Find ROMs on this device".
class FindOnlineScreen extends StatefulWidget {
  const FindOnlineScreen({super.key});

  @override
  State<FindOnlineScreen> createState() => _FindOnlineScreenState();
}

class _FindOnlineScreenState extends State<FindOnlineScreen> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _open(String url) async {
    final s = servicesOf(context);
    final messenger = ScaffoldMessenger.of(context);
    if (!await s.gateway.openUrl(url)) {
      messenger.showSnackBar(const SnackBar(content: Text('No web browser on this device can open the link.')));
    }
  }

  void _search() {
    final q = _query.text.trim();
    if (q.isEmpty) return;
    _open(webSearchUrl(q));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageFrame(
          title: 'Find games online',
          subtitle: 'Search the web in your browser, or open sources of free homebrew games.',
          actions: [
            TvButton(label: 'Back', icon: Icons.arrow_back_rounded, onPressed: () => Navigator.of(context).pop()),
          ],
          child: ListView(children: [
            const SectionHeader('Search the web'),
            Row(children: [
              Expanded(
                child: TextField(
                  key: const ValueKey('web-search'),
                  controller: _query,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _search(),
                  decoration: const InputDecoration(
                    hintText: 'Type what you are looking for',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              TvButton(label: 'Search', icon: Icons.open_in_browser_rounded, primary: true, onPressed: _search),
            ]),
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                'Opens your web browser with this search. Only download games you own or that are free to share '
                '(homebrew, public domain): most commercial games on the web are shared without permission.',
                style: TextStyle(color: Colors.white60, fontSize: 12.5),
              ),
            ),
            const SizedBox(height: 18),
            const SectionHeader('Free homebrew games'),
            for (final src in homebrewSources)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TvFocusable(
                  scale: 1.01,
                  padding: const EdgeInsets.all(12),
                  onSelect: () => _open(src.url),
                  child: Row(children: [
                    const Icon(Icons.public_rounded),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(src.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text(src.description, style: const TextStyle(fontSize: 12, color: Colors.white60)),
                      ]),
                    ),
                    const Text('Open', style: TextStyle(color: Colors.white54)),
                  ]),
                ),
              ),
            const SizedBox(height: 18),
            const SectionHeader('After downloading'),
            const Text(
              'Games you download in the browser land in the Download folder. "Find ROMs on this device" '
              'finds them and puts them in ROMs/<system>/ for GAMEBOX.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TvButton(
                label: 'Find ROMs on this device',
                icon: Icons.travel_explore_rounded,
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RomSearchScreen())),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
