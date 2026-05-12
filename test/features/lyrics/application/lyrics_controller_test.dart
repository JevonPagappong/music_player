import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/core/database/app_database.dart';
import 'package:music_player/core/models/lyrics.dart';
import 'package:music_player/features/lyrics/application/lyrics_controller.dart';
import 'package:music_player/features/lyrics/data/lyrics_repository.dart';

void main() {
  group('LyricsController', () {
    test('saves and loads manual lyrics', () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final repository = LyricsRepository(database);
      final controller = LyricsController(
        repository: repository,
        idGenerator: () => 'lyrics-1',
        now: () => DateTime.utc(2026, 5, 12),
      );

      await controller.saveManualLyrics(
        songId: 'song-1',
        plainText: '  Line one\nLine two  ',
      );

      final lyrics = await controller.getLyricsForSong('song-1');

      expect(lyrics, isNotNull);
      expect(lyrics!.lyricsId, 'lyrics-1');
      expect(lyrics.songId, 'song-1');
      expect(lyrics.sourceType, LyricsSourceType.manual);
      expect(lyrics.plainText, 'Line one\nLine two');
      expect(lyrics.updatedAt, DateTime.utc(2026, 5, 12));
    });

    test('clears lyrics for a song', () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final repository = LyricsRepository(database);
      final controller = LyricsController(
        repository: repository,
        idGenerator: () => 'lyrics-1',
        now: () => DateTime.utc(2026, 5, 12),
      );

      await controller.saveManualLyrics(
        songId: 'song-1',
        plainText: 'Lyrics',
      );

      await controller.clearLyricsForSong('song-1');

      final lyrics = await controller.getLyricsForSong('song-1');

      expect(lyrics, isNull);
    });
  });
}