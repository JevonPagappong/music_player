import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/models/song.dart';
import '../../library/application/library_controller_provider.dart';
import '../data/playlist_repository_provider.dart';

final manualPlaylistsProvider = FutureProvider<List<PlaylistRecord>>((ref) {
  final repository = ref.watch(playlistRepositoryProvider);

  return repository.getManualPlaylists();
});

final manualPlaylistSongsProvider =
    FutureProvider.family<List<Song>, String>((ref, playlistId) async {
  final playlistRepository = ref.watch(playlistRepositoryProvider);
  final libraryController = ref.watch(libraryControllerProvider);

  final songIds = await playlistRepository.getPlaylistSongIds(playlistId);
  final allSongs = await libraryController.loadSongs();

  final songsById = {
    for (final song in allSongs) song.songId: song,
  };

  return [
    for (final songId in songIds)
      if (songsById[songId] != null) songsById[songId]!,
  ];
});