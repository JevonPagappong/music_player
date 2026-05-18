import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/song.dart';
import '../../application/library_controller_provider.dart';
import '../../application/library_state_provider.dart';

Future<void> showEditSongInfoSheet({
  required BuildContext context,
  required WidgetRef ref,
  required Song song,
  VoidCallback? onSaved,
}) async {
  final edited = await showDialog<_EditedSongInfo>(
    context: context,
    builder: (context) {
      return _EditSongInfoDialog(song: song);
    },
  );

  if (edited == null) {
    return;
  }

  await ref.read(libraryControllerProvider).updateSongInfo(
        songId: song.songId,
        title: edited.title.trim(),
        artist: edited.artist.trim(),
        album: edited.album.trim(),
      );

  ref.invalidate(librarySongsProvider);
  ref.invalidate(favoriteSongsProvider);
  ref.invalidate(recentlyAddedSongsProvider);
  ref.invalidate(mostPlayedSongsProvider);
  onSaved?.call();

  if (!context.mounted) {
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Song info berhasil disimpan.')),
  );
}

class _EditSongInfoDialog extends StatefulWidget {
  const _EditSongInfoDialog({
    required this.song,
  });

  final Song song;

  @override
  State<_EditSongInfoDialog> createState() => _EditSongInfoDialogState();
}

class _EditSongInfoDialogState extends State<_EditSongInfoDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _artistController;
  late final TextEditingController _albumController;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.song.title);
    _artistController = TextEditingController(text: widget.song.artist);
    _albumController = TextEditingController(text: widget.song.album);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _albumController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();

    Navigator.of(context).pop(
      _EditedSongInfo(
        title: _titleController.text,
        artist: _artistController.text,
        album: _albumController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit song info'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Title'),
              textInputAction: TextInputAction.next,
            ),
            TextField(
              controller: _artistController,
              decoration: const InputDecoration(labelText: 'Artist'),
              textInputAction: TextInputAction.next,
            ),
            TextField(
              controller: _albumController,
              decoration: const InputDecoration(labelText: 'Album'),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Duration: ${_formatDuration(widget.song.durationMs)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            FocusManager.instance.primaryFocus?.unfocus();
            Navigator.of(context).pop();
          },
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Simpan'),
        ),
      ],
    );
  }

  String _formatDuration(int durationMs) {
    if (durationMs <= 0) {
      return 'Unknown';
    }

    final duration = Duration(milliseconds: durationMs);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class _EditedSongInfo {
  const _EditedSongInfo({
    required this.title,
    required this.artist,
    required this.album,
  });

  final String title;
  final String artist;
  final String album;
}