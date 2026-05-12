import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/song_repository_provider.dart';
import 'song_import_preparer_provider.dart';
import 'song_import_service.dart';

final songImportServiceProvider = Provider<SongImportService>((ref) {
  return SongImportService(
    preparer: ref.watch(songImportPreparerProvider),
    repository: ref.watch(songRepositoryProvider),
  );
});