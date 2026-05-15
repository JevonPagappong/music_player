import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'import_songs_controller.dart';
import 'song_file_storage_provider.dart';
import 'song_import_service_provider.dart';

final importSongsControllerProvider = Provider<ImportSongsController>((ref) {
  return ImportSongsController(
    importService: ref.watch(songImportServiceProvider),
    fileStorage: ref.watch(songFileStorageProvider),
  );
});