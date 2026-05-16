import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'song_metadata_reader.dart';

final songMetadataReaderProvider = Provider<SongMetadataReader>((ref) {
  return const SongMetadataReader();
});