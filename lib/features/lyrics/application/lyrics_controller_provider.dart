import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/lyrics_repository_provider.dart';
import 'lyrics_controller.dart';

final lyricsControllerProvider = Provider<LyricsController>((ref) {
  return LyricsController(
    repository: ref.watch(lyricsRepositoryProvider),
  );
});