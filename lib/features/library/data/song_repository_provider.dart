import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import 'song_repository.dart';

final songRepositoryProvider = Provider<SongRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);

  return SongRepository(database);
});