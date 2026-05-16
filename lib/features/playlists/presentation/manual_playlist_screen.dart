import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_theme.dart';
import '../../library/application/library_controller_provider.dart';
import '../../library/application/library_state_provider.dart';
import '../../library/presentation/widgets/song_tile.dart';
import '../../player/application/player_controller_provider.dart';
import '../application/playlist_state_provider.dart';
import '../data/playlist_repository_provider.dart';
import '../../library/presentation/widgets/edit_song_info_sheet.dart';
import '../../library/presentation/widgets/delete_song_dialog.dart';

class ManualPlaylistScreen extends ConsumerWidget {
  const ManualPlaylistScreen({
    required this.playlistId,
    required this.playlistName,
    super.key,
  });

  final String playlistId;
  final String playlistName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(manualPlaylistSongsProvider(playlistId));

    return Scaffold(
      appBar: AppBar(
        title: Text(playlistName),
        actions: [
          IconButton(
            tooltip: 'Tambah lagu',
            onPressed: () => _showAddSongsSheet(context, ref),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: songsAsync.when(
        data: (songs) {
          if (songs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Playlist ini masih kosong.\nTap tombol + untuk menambahkan lagu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];

              return Dismissible(
                key: ValueKey('${playlistId}_${song.songId}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.redAccent,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) async {
                  await ref.read(playlistRepositoryProvider).removeSongFromPlaylist(
                        playlistId: playlistId,
                        songId: song.songId,
                      );

                  ref.invalidate(manualPlaylistSongsProvider(playlistId));

                  if (!context.mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${song.title} dihapus dari playlist.')),
                  );
                },
                child: SongTile(
                  onEditPressed: () => showEditSongInfoSheet(
                    context: context,
                    ref: ref,
                    song: song,
                    onSaved: () {
                      ref.invalidate(manualPlaylistSongsProvider(playlistId));
                    },
                  ),
                  song: song,
                  onTap: () async {
                    ref.read(libraryControllerProvider).recordPlayed(song.songId);
                    await ref.read(playerControllerProvider).playSong(
                          song,
                          queue: songs,
                        );
                    ref.invalidate(librarySongsProvider);
                    ref.invalidate(recentlyAddedSongsProvider);
                    ref.invalidate(mostPlayedSongsProvider);
                  },
                  onFavoritePressed: () async {
                    await ref.read(libraryControllerProvider).setFavorite(
                          song.songId,
                          !song.isFavorite,
                        );
                    ref.invalidate(librarySongsProvider);
                    ref.invalidate(favoriteSongsProvider);
                    ref.invalidate(manualPlaylistSongsProvider(playlistId));
                  },
                  onDeletePressed: () => showDeleteSongDialog(
                    context: context,
                    ref: ref,
                    song: song,
                    onDeleted: () {
                      ref.invalidate(manualPlaylistSongsProvider(playlistId));
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showAddSongsSheet(BuildContext context, WidgetRef ref) async {
    final allSongs = await ref.read(librarySongsProvider.future);
    final playlistSongs = await ref.read(manualPlaylistSongsProvider(playlistId).future);
    final existingSongIds = playlistSongs.map((song) => song.songId).toSet();

    if (!context.mounted) {
      return;
    }

    if (allSongs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Import lagu terlebih dahulu.')),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surface,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            children: [
              const Text(
                'Tambah lagu ke playlist',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              ...allSongs.map((song) {
                final alreadyAdded = existingSongIds.contains(song.songId);

                return ListTile(
                  enabled: !alreadyAdded,
                  leading: Icon(
                    alreadyAdded ? Icons.check_circle : Icons.music_note,
                    color: alreadyAdded
                        ? AppTheme.primary
                        : AppTheme.textSecondary,
                  ),
                  title: Text(
                    song.title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    song.artist,
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                  trailing: alreadyAdded
                      ? const Text(
                          'Sudah ada',
                          style: TextStyle(color: AppTheme.textSecondary),
                        )
                      : const Icon(
                          Icons.add,
                          color: AppTheme.primary,
                        ),
                  onTap: alreadyAdded
                      ? null
                      : () async {
                          await ref.read(playlistRepositoryProvider).addSongToPlaylist(
                                playlistId: playlistId,
                                songId: song.songId,
                                position: playlistSongs.length,
                                addedAt: DateTime.now().toUtc(),
                              );

                          ref.invalidate(manualPlaylistSongsProvider(playlistId));

                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}