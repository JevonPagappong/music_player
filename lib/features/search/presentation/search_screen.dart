import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_theme.dart';
import '../../library/application/library_state_provider.dart';
import '../../library/presentation/widgets/song_tile.dart';
import '../../library/application/library_controller_provider.dart';
import '../../player/application/player_controller_provider.dart';
import '../../library/presentation/widgets/edit_song_info_sheet.dart';
import '../../library/presentation/widgets/delete_song_dialog.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(searchResultsProvider(_query));

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Search',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            onChanged: (value) {
              setState(() {
                _query = value;
              });
            },
            decoration: const InputDecoration(
              hintText: 'Cari lagu, artist, atau album',
              prefixIcon: Icon(Icons.search),
              filled: true,
              fillColor: AppTheme.surfaceLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(14)),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: resultsAsync.when(
              data: (songs) {
                if (_query.trim().isEmpty) {
                  return const _SearchHint();
                }

                if (songs.isEmpty) {
                  return const _EmptySearch();
                }

                return ListView(
                  children: songs
                      .map(
                        (song) => SongTile(
                          onEditPressed: () => showEditSongInfoSheet(
                            context: context,
                            ref: ref,
                            song: song,
                            onSaved: () {
                              ref.invalidate(searchResultsProvider(_query));
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
                            ref.invalidate(searchResultsProvider(_query));
                          },
                          onDeletePressed: () => showDeleteSongDialog(
                            context: context,
                            ref: ref,
                            song: song,
                            onDeleted: () {
                              ref.invalidate(searchResultsProvider(_query));
                            },
                          ),
                        )
                      )
                      .toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Text(
                error.toString(),
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchHint extends StatelessWidget {
  const _SearchHint();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Ketik judul lagu, artist, atau album untuk mencari library lokal.',
      style: TextStyle(color: AppTheme.textSecondary),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Tidak ada lagu yang cocok.',
      style: TextStyle(color: AppTheme.textSecondary),
    );
  }
}