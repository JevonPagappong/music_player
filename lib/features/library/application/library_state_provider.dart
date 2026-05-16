import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/song.dart';
import 'library_controller_provider.dart';

final librarySongsProvider = FutureProvider<List<Song>>((ref) {
  final controller = ref.watch(libraryControllerProvider);

  return controller.loadSongs();
});

final libraryStorageBytesProvider = FutureProvider<int>((ref) {
  final controller = ref.watch(libraryControllerProvider);

  return controller.getTotalStorageBytes();
});

final favoriteSongsProvider = FutureProvider<List<Song>>((ref) {
  final controller = ref.watch(libraryControllerProvider);

  return controller.loadFavoriteSongs();
});

final recentlyAddedSongsProvider = FutureProvider<List<Song>>((ref) {
  final controller = ref.watch(libraryControllerProvider);

  return controller.loadRecentlyAddedSongs();
});

final mostPlayedSongsProvider = FutureProvider<List<Song>>((ref) {
  final controller = ref.watch(libraryControllerProvider);

  return controller.loadMostPlayedSongs();
});

final searchResultsProvider =
    FutureProvider.family<List<Song>, String>((ref, query) {
  final controller = ref.watch(libraryControllerProvider);

  return controller.searchSongs(query);
});