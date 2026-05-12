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
  final titleController = TextEditingController(text: song.title);
  final artistController = TextEditingController(text: song.artist);
  final albumController = TextEditingController(text: song.album);

  final edited = await showDialog<_EditedSongInfo>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Edit song info'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: artistController,
                decoration: const InputDecoration(labelText: 'Artist'),
              ),
              TextField(
                controller: albumController,
                decoration: const InputDecoration(labelText: 'Album'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop(
                _EditedSongInfo(
                  title: titleController.text,
                  artist: artistController.text,
                  album: albumController.text,
                ),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      );
    },
  );

  titleController.dispose();
  artistController.dispose();
  albumController.dispose();

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