import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/core/database/app_database.dart';
import 'package:music_player/core/models/audio_format.dart';
import 'package:music_player/core/models/song.dart';
import 'package:music_player/features/library/data/song_repository.dart';

void main() {
  group('SongRepository', () {
    test('saves and returns songs ordered by import date descending', () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final repository = SongRepository(database);

      final older = DateTime.utc(2026, 5, 11);
      final newer = DateTime.utc(2026, 5, 12);

      await repository.saveSong(
        Song(
          songId: 'song-old',
          filePath: '/music/old.mp3',
          originalFileName: 'old.mp3',
          title: 'Old Song',
          artist: 'Artist A',
          album: 'Album A',
          durationMs: 180000,
          format: AudioFormat.mp3,
          fileSizeBytes: 1000,
          playCount: 0,
          isFavorite: false,
          importedAt: older,
          updatedAt: older,
        ),
      );

      await repository.saveSong(
        Song(
          songId: 'song-new',
          filePath: '/music/new.m4a',
          originalFileName: 'new.m4a',
          title: 'New Song',
          artist: 'Artist B',
          album: 'Album B',
          durationMs: 210000,
          format: AudioFormat.m4a,
          fileSizeBytes: 2000,
          playCount: 0,
          isFavorite: false,
          importedAt: newer,
          updatedAt: newer,
        ),
      );

      final songs = await repository.getAllSongs();

      expect(songs, hasLength(2));
      expect(songs.first.songId, 'song-new');
      expect(songs.last.songId, 'song-old');
    });

    test('updates favorite state', () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final repository = SongRepository(database);
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

      await repository.setFavorite('song-1', true, updatedAt: now);

      final songs = await repository.getAllSongs();

      expect(songs.single.isFavorite, isTrue);
    });

    test('increments play count and stores last played date', () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final repository = SongRepository(database);
      final importedAt = DateTime.utc(2026, 5, 12);
      final playedAt = DateTime.utc(2026, 5, 13);

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

      await repository.incrementPlayCount('song-1', playedAt: playedAt);

      final songs = await repository.getAllSongs();

      expect(songs.single.playCount, 1);
      expect(songs.single.lastPlayedAt, playedAt);
    });
  });
}