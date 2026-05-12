import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/core/database/app_database.dart';
import 'package:music_player/core/models/audio_format.dart';
import 'package:music_player/core/models/song.dart';
import 'package:music_player/features/library/application/library_controller.dart';
import 'package:music_player/features/library/data/song_repository.dart';

void main() {
  group('LibraryController', () {
    test('loads all songs from repository', () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final repository = SongRepository(database);
      final controller = LibraryController(repository: repository);

      final now = DateTime.utc(2026, 5, 12);

      await repository.saveSong(
        Song(
          songId: 'song-1',
          filePath: '/music/song-1.mp3',
          originalFileName: 'song-1.mp3',
          title: 'Song One',
          artist: 'Artist One',
          album: 'Album One',
          durationMs: 180000,
          format: AudioFormat.mp3,
          fileSizeBytes: 1000,
          playCount: 0,
          isFavorite: false,
          importedAt: now,
          updatedAt: now,
        ),
      );

      final songs = await controller.loadSongs();

      expect(songs, hasLength(1));
      expect(songs.single.title, 'Song One');
    });

    test('searches songs by keyword', () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final repository = SongRepository(database);
      final controller = LibraryController(repository: repository);

      final now = DateTime.utc(2026, 5, 12);

      await repository.saveSong(
        Song(
          songId: 'song-1',
          filePath: '/music/moon.mp3',
          originalFileName: 'moon.mp3',
          title: 'Moonlight',
          artist: 'Artist One',
          album: 'Album One',
          durationMs: 180000,
          format: AudioFormat.mp3,
          fileSizeBytes: 1000,
          playCount: 0,
          isFavorite: false,
          importedAt: now,
          updatedAt: now,
        ),
      );

      await repository.saveSong(
        Song(
          songId: 'song-2',
          filePath: '/music/sun.mp3',
          originalFileName: 'sun.mp3',
          title: 'Sunrise',
          artist: 'Artist Two',
          album: 'Album Two',
          durationMs: 180000,
          format: AudioFormat.mp3,
          fileSizeBytes: 1000,
          playCount: 0,
          isFavorite: false,
          importedAt: now,
          updatedAt: now,
        ),
      );

      final songs = await controller.searchSongs('Moon');

      expect(songs, hasLength(1));
      expect(songs.single.songId, 'song-1');
    });

    test('toggles favorite state', () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final repository = SongRepository(database);
      final controller = LibraryController(
        repository: repository,
        now: () => DateTime.utc(2026, 5, 13),
      );

      final importedAt = DateTime.utc(2026, 5, 12);

      await repository.saveSong(
        Song(
          songId: 'song-1',
          filePath: '/music/song-1.mp3',
          originalFileName: 'song-1.mp3',
          title: 'Song One',
          artist: 'Artist One',
          album: 'Album One',
          durationMs: 180000,
          format: AudioFormat.mp3,
          fileSizeBytes: 1000,
          playCount: 0,
          isFavorite: false,
          importedAt: importedAt,
          updatedAt: importedAt,
        ),
      );

      await controller.setFavorite('song-1', true);

      final songs = await controller.loadSongs();

      expect(songs.single.isFavorite, isTrue);
      expect(songs.single.updatedAt, DateTime.utc(2026, 5, 13));
    });

    test('records played song for Most Played', () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final repository = SongRepository(database);
      final controller = LibraryController(
        repository: repository,
        now: () => DateTime.utc(2026, 5, 13),
      );

      final importedAt = DateTime.utc(2026, 5, 12);

      await repository.saveSong(
        Song(
          songId: 'song-1',
          filePath: '/music/song-1.mp3',
          originalFileName: 'song-1.mp3',
          title: 'Song One',
          artist: 'Artist One',
          album: 'Album One',
          durationMs: 180000,
          format: AudioFormat.mp3,
          fileSizeBytes: 1000,
          playCount: 0,
          isFavorite: false,
          importedAt: importedAt,
          updatedAt: importedAt,
        ),
      );

      await controller.recordPlayed('song-1');

      final songs = await controller.loadSongs();

      expect(songs.single.playCount, 1);
      expect(songs.single.lastPlayedAt, DateTime.utc(2026, 5, 13));
    });
  });
}