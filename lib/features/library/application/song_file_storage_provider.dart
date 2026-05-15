import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'song_file_storage.dart';

final songFileStorageProvider = Provider<SongFileStorage>((ref) {
  return const SongFileStorage();
});