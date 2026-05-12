import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/lyrics.dart';
import 'lyrics_controller_provider.dart';

final lyricsForSongProvider =
    FutureProvider.family<Lyrics?, String>((ref, songId) {
  final controller = ref.watch(lyricsControllerProvider);

  return controller.getLyricsForSong(songId);
});