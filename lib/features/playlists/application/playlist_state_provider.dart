import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../data/playlist_repository_provider.dart';

final manualPlaylistsProvider = FutureProvider<List<PlaylistRecord>>((ref) {
  final repository = ref.watch(playlistRepositoryProvider);

  return repository.getManualPlaylists();
});