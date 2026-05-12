import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/core/database/app_database.dart';
import 'package:music_player/core/models/lyrics.dart';
import 'package:music_player/features/lyrics/data/lyrics_repository.dart';

void main() {
  group('LyricsRepository', () {
    test('returns null when lyrics are not available', () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final repository = LyricsRepository(database);

      final lyrics = await repository.getLyricsForSong('song-1');

      expect(lyrics, isNull);
    });

    test('saves manual lyrics for a song', () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final repository = LyricsRepository(database);
      final updatedAt = DateTime.utc(2026, 5, 12);

      await repository.saveManualLyrics(
        lyricsId: 'lyrics-1',
        songId: 'song-1',
        plainText: 'Line one\nLine two',
        updatedAt: updatedAt,
      );

      final lyrics = await repository.getLyricsForSong('song-1');

      expect(lyrics, isNotNull);
      expect(lyrics!.lyricsId, 'lyrics-1');
      expect(lyrics.songId, 'song-1');
      expect(lyrics.sourceType, LyricsSourceType.manual);
      expect(lyrics.plainText, 'Line one\nLine two');
      expect(lyrics.lrcPath, isNull);
      expect(lyrics.updatedAt, updatedAt);
    });

    test('replaces old manual lyrics for the same song', () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final repository = LyricsRepository(database);

      await repository.saveManualLyrics(
        lyricsId: 'lyrics-old',
        songId: 'song-1',
        plainText: 'Old lyrics',
        updatedAt: DateTime.utc(2026, 5, 12),
      );

      await repository.saveManualLyrics(
        lyricsId: 'lyrics-new',
        songId: 'song-1',
        plainText: 'New lyrics',
        updatedAt: DateTime.utc(2026, 5, 13),
      );

      final lyrics = await repository.getLyricsForSong('song-1');
      final allRows = await database.select(database.lyricsEntries).get();

      expect(allRows, hasLength(1));
      expect(lyrics!.lyricsId, 'lyrics-new');
      expect(lyrics.plainText, 'New lyrics');
    });

    test('saves lrc lyrics reference for a song', () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final repository = LyricsRepository(database);
      final updatedAt = DateTime.utc(2026, 5, 12);

      await repository.saveLrcLyrics(
        lyricsId: 'lyrics-lrc-1',
        songId: 'song-1',
        lrcPath: '/lyrics/song-1.lrc',
        timingData: '[00:01.00]Line one',
        updatedAt: updatedAt,
      );

      final lyrics = await repository.getLyricsForSong('song-1');

      expect(lyrics, isNotNull);
      expect(lyrics!.sourceType, LyricsSourceType.lrcFile);
      expect(lyrics.lrcPath, '/lyrics/song-1.lrc');
      expect(lyrics.timingData, '[00:01.00]Line one');
      expect(lyrics.plainText, isNull);
      expect(lyrics.updatedAt, updatedAt);
    });

    test('clears lyrics for a song', () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final repository = LyricsRepository(database);

      await repository.saveManualLyrics(
        lyricsId: 'lyrics-1',
        songId: 'song-1',
        plainText: 'Lyrics to delete',
        updatedAt: DateTime.utc(2026, 5, 12),
      );

      await repository.clearLyricsForSong('song-1');

      final lyrics = await repository.getLyricsForSong('song-1');

      expect(lyrics, isNull);
    });
  });
}