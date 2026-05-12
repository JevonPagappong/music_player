import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/core/database/app_database.dart';
import 'package:music_player/core/models/audio_format.dart';
import 'package:music_player/core/models/song.dart';
import 'package:music_player/features/library/data/song_repository.dart';

void main() {
  group('SongRepository updateSongInfo', () {
    test('updates title artist and album without changing playback fields', () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final repository = SongRepository(database);
      final importedAt = DateTime.utc(2026, 5, 12);
      final updatedAt = DateTime.utc(2026, 5, 13);

      await repository.saveSong(
        Song(
          songId: 'song-1',
          filePath: '/music/song-1.mp3',
          originalFileName: 'song-1.mp3',
          title: 'Old Title',
          artist: 'Old Artist',
          album: 'Old Album',
          durationMs: 180000,
          format: AudioFormat.mp3,
          fileSizeBytes: 1000,
          playCount: 2,
          isFavorite: true,
          importedAt: importedAt,
          updatedAt: importedAt,
        ),
      );

      await repository.updateSongInfo(
        songId: 'song-1',
        title: 'New Title',
        artist: 'New Artist',
        album: 'New Album',
        updatedAt: updatedAt,
      );

      final songs = await repository.getAllSongs();
      final song = songs.single;

      expect(song.title, 'New Title');
      expect(song.artist, 'New Artist');
      expect(song.album, 'New Album');
      expect(song.playCount, 2);
      expect(song.isFavorite, isTrue);
      expect(song.updatedAt, updatedAt);
    });
  });
}