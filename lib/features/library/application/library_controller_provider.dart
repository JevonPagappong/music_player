import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/song_repository_provider.dart';
import 'library_controller.dart';

final libraryControllerProvider = Provider<LibraryController>((ref) {
  return LibraryController(
    repository: ref.watch(songRepositoryProvider),
  );
});