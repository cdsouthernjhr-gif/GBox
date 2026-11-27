import 'package:flutter/material.dart';

import '../../core/constants/custom_console.dart';
import '../../shared/widgets/tv_widgets.dart';

/// Adds a system GAMEBOX doesn't list (or, with [existing], edits or removes
/// it). Returns the system's id when saved.
Future<String?> showCustomConsoleDialog(BuildContext context, {CustomConsole? existing}) => showDialog<String>(
  context: context,
  builder: (_) => _CustomConsoleDialog(existing: existing),
);

class _CustomConsoleDialog extends StatefulWidget {
  const _CustomConsoleDialog({this.existing});
  final CustomConsole? existing;

  @override
  State<_CustomConsoleDialog> createState() => _CustomConsoleDialogState();
}

class _CustomConsoleDialogState extends State<_CustomConsoleDialog> {
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _folder = TextEditingController(text: widget.existing?.folder);
  late final _exts = TextEditingController(text: widget.existing?.extensions.join(', '));
  // The folder follows the name until the user types one.
  late bool _folderEdited = widget.existing != null;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _folder.dispose();
    _exts.dispose();
    super.dispose();
  }

  List<CustomConsole> get _others => [
    for (final c in servicesOf(context).settings.state.value.customConsoles)
      if (c.id != widget.existing?.id) c,
  ];

  Future<void> _save() async {
    final s = servicesOf(context);
    final name = _name.text.trim();
    // Editing keeps the folder (and id) so the games stay with the system.
    final folder = widget.existing?.folder ?? _folder.text.trim().toLowerCase();
    final exts = CustomConsole.parseExtensions(_exts.text);
    final problem = CustomConsole.problem(name, folder, exts, _others);
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    final c = CustomConsole(id: CustomConsole.idFor(folder), name: name, folder: folder, extensions: exts);
    await s.settings.setCustomConsoles([..._others, c]);
    if (mounted) Navigator.pop(context, c.id);
  }

  Future<void> _remove() async {
    final s = servicesOf(context);
    final id = widget.existing!.id;
    final counts = await s.db.watchGameCountsByConsole().first;
    if (!mounted) return;
    final games = counts[id] ?? 0;
    if (games > 0) {
      setState(
        () => _error =
            'This system has $games game(s) in the library. Remove them from the library '
            '(GAMES → game → Remove from library) before removing the system.',
      );
      return;
    }
    await s.settings.setCustomConsoles(_others);
    await s.settings.setCustomEmulators([
      for (final e in s.settings.state.value.customEmulators)
        if (e.consoleIds.length > 1 || !e.consoleIds.contains(id)) e.copyWithout(id),
    ]);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    return AlertDialog(
      title: Text(editing ? 'Edit system' : 'Add a system'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'For a console or system GAMEBOX doesn\'t list (e.g. Neo Geo, arcade, Atari 2600).',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 10),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _error!,
                    key: const ValueKey('console-error'),
                    style: const TextStyle(color: Colors.orangeAccent),
                  ),
                ),
              TextField(
                key: const ValueKey('console-name'),
                controller: _name,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Name', hintText: 'e.g. Neo Geo'),
                onChanged: (v) {
                  if (!_folderEdited) _folder.text = CustomConsole.folderFor(v);
                },
              ),
              const SizedBox(height: 8),
              TextField(
                key: const ValueKey('console-folder'),
                controller: _folder,
                enabled: !editing,
                decoration: InputDecoration(
                  labelText: 'Games folder',
                  prefixText: 'ROMs/',
                  helperText: editing ? 'The folder can\'t be changed (games are filed under it).' : null,
                ),
                onChanged: (_) => _folderEdited = true,
              ),
              const SizedBox(height: 8),
              TextField(
                key: const ValueKey('console-exts'),
                controller: _exts,
                decoration: const InputDecoration(labelText: 'File types', hintText: 'e.g. zip, neo'),
              ),
              const SizedBox(height: 10),
              const Text(
                'Put the games in ROMs/<folder>/ and scan: files of these types there are added to this system. '
                'Then add an emulator for it (EMULATORS → Add emulator). GAMEBOX has no hardware estimate for systems '
                'you add.',
                style: TextStyle(fontSize: 12.5, color: Colors.white60),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        if (editing) TextButton(onPressed: _remove, child: const Text('Remove')),
        TextButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
