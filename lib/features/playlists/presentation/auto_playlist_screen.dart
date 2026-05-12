import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_theme.dart';
import '../../library/application/library_controller_provider.dart';
import '../../library/application/library_state_provider.dart';
import '../../library/presentation/widgets/song_tile.dart';
import '../../player/application/player_controller_provider.dart';
import '../../library/presentation/widgets/edit_song_info_sheet.dart';

class AutoPlaylistScreen extends ConsumerWidget {
  const AutoPlaylistScreen({
    required this.type,
    super.key,
  });

  final AutoPlaylistType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = switch (type) {
      AutoPlaylistType.favorites => ref.watch(favoriteSongsProvider),
      AutoPlaylistType.recentlyAdded => ref.watch(recentlyAddedSongsProvider),
      AutoPlaylistType.mostPlayed => ref.watch(mostPlayedSongsProvider),
    };

    return Scaffold(
      appBar: AppBar(title: Text(type.title)),
      body: songsAsync.when(
        data: (songs) {
          if (songs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  type.emptyMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];

              return SongTile(
                onEditPressed: () => showEditSongInfoSheet(
                  context: context,
                  ref: ref,
                  song: song,
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
                  ref.invalidate(recentlyAddedSongsProvider);
                  ref.invalidate(mostPlayedSongsProvider);
                },
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
}

enum AutoPlaylistType {
  favorites,
  recentlyAdded,
  mostPlayed;

  String get title {
    return switch (this) {
      AutoPlaylistType.favorites => 'Favorites',
      AutoPlaylistType.recentlyAdded => 'Recently Added',
      AutoPlaylistType.mostPlayed => 'Most Played',
    };
  }

  String get emptyMessage {
    return switch (this) {
      AutoPlaylistType.favorites =>
        'Belum ada lagu favorit. Tap ikon hati pada lagu untuk menambahkannya.',
      AutoPlaylistType.recentlyAdded =>
        'Belum ada lagu yang diimport.',
      AutoPlaylistType.mostPlayed =>
        'Belum ada lagu yang diputar.',
    };
  }

  static AutoPlaylistType fromPathValue(String value) {
    return switch (value) {
      'favorites' => AutoPlaylistType.favorites,
      'recently-added' => AutoPlaylistType.recentlyAdded,
      'most-played' => AutoPlaylistType.mostPlayed,
      _ => AutoPlaylistType.favorites,
    };
  }
}