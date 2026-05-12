import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import 'lyrics_repository.dart';

final lyricsRepositoryProvider = Provider<LyricsRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);

  return LyricsRepository(database);
});