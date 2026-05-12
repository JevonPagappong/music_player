import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/core/database/app_database.dart';
import 'package:music_player/core/errors/app_error.dart';
import 'package:music_player/core/models/audio_format.dart';
import 'package:music_player/features/library/application/song_import_preparer.dart';
import 'package:music_player/features/library/application/song_import_service.dart';
import 'package:music_player/features/library/data/song_repository.dart';

void main() {
  group('SongImportService', () {
    test('prepares and saves an imported song', () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final repository = SongRepository(database);
      final preparer = SongImportPreparer(
        idGenerator: () => 'song-1',
        now: () => DateTime.utc(2026, 5, 12),
      );

      final service = SongImportService(
        preparer: preparer,
        repository: repository,
      );

      final importedSong = await service.importPreparedFile(
        source: const ImportSourceFile(
          originalFileName: 'track.mp3',
          copiedFilePath: '/app/music/song-1.mp3',
          fileSizeBytes: 123456,
        ),
        metadata: const ImportedSongMetadata(
          title: 'Track Title',
          artist: 'Artist Name',
          album: 'Album Name',
          durationMs: 180000,
        ),
      );

      final songs = await repository.getAllSongs();

      expect(importedSong.songId, 'song-1');
      expect(importedSong.title, 'Track Title');
      expect(importedSong.format, AudioFormat.mp3);

      expect(songs, hasLength(1));
      expect(songs.single.songId, 'song-1');
      expect(songs.single.title, 'Track Title');
      expect(songs.single.artist, 'Artist Name');
      expect(songs.single.album, 'Album Name');
    });

    test('does not save unsupported audio files', () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final repository = SongRepository(database);
      final preparer = SongImportPreparer(
        idGenerator: () => 'song-1',
        now: () => DateTime.utc(2026, 5, 12),
      );

      final service = SongImportService(
        preparer: preparer,
        repository: repository,
      );

      await expectLater(
        service.importPreparedFile(
          source: const ImportSourceFile(
            originalFileName: 'track.flac',
            copiedFilePath: '/app/music/song-1.flac',
            fileSizeBytes: 123456,
          ),
          metadata: const ImportedSongMetadata.empty(),
        ),
        throwsA(isA<UnsupportedAudioFormatError>()),
      );

      final songs = await repository.getAllSongs();

      expect(songs, isEmpty);
    });
  });
}