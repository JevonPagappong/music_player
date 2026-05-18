import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/features/library/application/song_metadata_reader.dart';

void main() {
  group('SongMetadataReader', () {
    test('uses file name fallback metadata safely', () async {
      const reader = SongMetadataReader();

      final metadata = await reader.readMetadata(
        originalFileName: 'song-title.mp3',
        filePath: '',
      );

      expect(metadata.title, 'song-title');
      expect(metadata.artist, '');
      expect(metadata.album, '');
      expect(metadata.durationMs, 0);
    });
  });
}