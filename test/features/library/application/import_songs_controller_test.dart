import 'package:drift/native.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/core/database/app_database.dart';
import 'package:music_player/core/models/audio_format.dart';
import 'package:music_player/features/library/application/import_songs_controller.dart';
import 'package:music_player/features/library/application/song_import_preparer.dart';
import 'package:music_player/features/library/application/song_import_service.dart';
import 'package:music_player/features/library/data/song_repository.dart';
import 'package:music_player/features/library/application/song_file_storage.dart';
import 'package:music_player/features/library/application/song_metadata_reader.dart';

void main() {
  group('ImportSongsController', () {
    test('imports picked files into the song repository', () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      var nextId = 0;

      final repository = SongRepository(database);
      final preparer = SongImportPreparer(
        idGenerator: () {
          nextId += 1;
          return 'song-$nextId';
        },
        now: () => DateTime.utc(2026, 5, 12),
      );
      final service = SongImportService(
        preparer: preparer,
        repository: repository,
      );
      final controller = ImportSongsController(
        importService: service,
        fileStorage: const FakeSongFileStorage(),
        metadataReader: const SongMetadataReader(),
      );

      final importedSongs = await controller.importPickedFiles([
        PlatformFile(
          name: 'first track.mp3',
          size: 100,
          path: '/downloads/first track.mp3',
        ),
        PlatformFile(
          name: 'second track.m4a',
          size: 200,
        ),
      ]);

      final songs = await repository.getAllSongs();

      expect(importedSongs, hasLength(2));
      expect(songs, hasLength(2));

      expect(songs[0].title, 'first track');
      expect(songs[0].format, AudioFormat.mp3);
      expect(songs[0].filePath, '/downloads/first track.mp3');

      expect(songs[1].title, 'second track');
      expect(songs[1].format, AudioFormat.m4a);
      expect(songs[1].filePath, 'picked-file://second track.m4a');
    });
  });
}

class FakeSongFileStorage extends SongFileStorage {
  const FakeSongFileStorage();

  @override
  Future<String> savePickedFile(PlatformFile file) async {
    final sourcePath = file.path;

    if (sourcePath != null && sourcePath.trim().isNotEmpty) {
      return sourcePath;
    }

    return 'picked-file://${file.name}';
  }
}