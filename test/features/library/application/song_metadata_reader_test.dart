import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/features/library/application/song_metadata_reader.dart';

void main() {
  group('SongMetadataReader', () {
    test('uses file name fallback metadata safely', () async {
      const reader = SongMetadataReader();

      final metadata = await reader.readMetadata(
        PlatformFile(
          name: 'my favorite song.mp3',
          size: 123,
          path: '/downloads/my favorite song.mp3',
        ),
      );

      expect(metadata.title, 'my favorite song');
      expect(metadata.artist, '');
      expect(metadata.album, '');
      expect(metadata.durationMs, 0);
    });
  });
}