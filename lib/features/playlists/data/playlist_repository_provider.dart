import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import 'playlist_repository.dart';

final playlistRepositoryProvider = Provider<PlaylistRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);

  return PlaylistRepository(database);
});