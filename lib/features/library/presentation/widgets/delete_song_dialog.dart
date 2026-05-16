import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/song.dart';
import '../../application/library_controller_provider.dart';
import '../../application/library_state_provider.dart';

Future<void> showDeleteSongDialog({
  required BuildContext context,
  required WidgetRef ref,
  required Song song,
  VoidCallback? onDeleted,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Hapus lagu?'),
        content: Text(
          '“${song.title}” akan dihapus dari library, playlist, dan lyrics lokal.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      );
    },
  );

  if (confirmed != true) {
    return;
  }

  await ref.read(libraryControllerProvider).deleteSong(song.songId);

  ref.invalidate(librarySongsProvider);
  ref.invalidate(favoriteSongsProvider);
  ref.invalidate(recentlyAddedSongsProvider);
  ref.invalidate(mostPlayedSongsProvider);
  ref.invalidate(libraryStorageBytesProvider);

  onDeleted?.call();

  if (!context.mounted) {
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('${song.title} dihapus dari library.')),
  );
}