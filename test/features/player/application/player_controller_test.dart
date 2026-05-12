import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/core/models/audio_format.dart';
import 'package:music_player/core/models/song.dart';
import 'package:music_player/features/player/application/player_controller.dart';

void main() {
  group('PlayerController', () {
    test('starts empty', () {
      final controller = PlayerController();
      addTearDown(controller.dispose);

      expect(controller.currentSong, isNull);
      expect(controller.isPlaying, isFalse);
      expect(controller.queue, isEmpty);
    });

    test('plays a selected song and creates a queue', () {
      final controller = PlayerController();
      addTearDown(controller.dispose);

      final song = _song('song-1', 'Track One');

      controller.playSong(song, queue: [song]);

      expect(controller.currentSong, song);
      expect(controller.queue, [song]);
      expect(controller.isPlaying, isTrue);
    });

    test('toggles play pause when a song is selected', () {
      final controller = PlayerController();
      addTearDown(controller.dispose);

      final song = _song('song-1', 'Track One');

      controller.playSong(song, queue: [song]);
      controller.togglePlayPause();

      expect(controller.isPlaying, isFalse);

      controller.togglePlayPause();

      expect(controller.isPlaying, isTrue);
    });

    test('does not toggle play pause without a selected song', () {
      final controller = PlayerController();
      addTearDown(controller.dispose);

      controller.togglePlayPause();

      expect(controller.currentSong, isNull);
      expect(controller.isPlaying, isFalse);
    });

    test('moves to next song in queue', () {
      final controller = PlayerController();
      addTearDown(controller.dispose);

      final songOne = _song('song-1', 'Track One');
      final songTwo = _song('song-2', 'Track Two');

      controller.playSong(songOne, queue: [songOne, songTwo]);
      controller.next();

      expect(controller.currentSong, songTwo);
      expect(controller.isPlaying, isTrue);
    });

    test('moves to previous song in queue', () {
      final controller = PlayerController();
      addTearDown(controller.dispose);

      final songOne = _song('song-1', 'Track One');
      final songTwo = _song('song-2', 'Track Two');

      controller.playSong(songTwo, queue: [songOne, songTwo]);
      controller.previous();

      expect(controller.currentSong, songOne);
      expect(controller.isPlaying, isTrue);
    });
  });
}

Song _song(String id, String title) {
  final now = DateTime.utc(2026, 5, 12);

  return Song(
    songId: id,
    filePath: '/music/$id.mp3',
    originalFileName: '$id.mp3',
    title: title,
    artist: 'Artist',
    album: 'Album',
    durationMs: 180000,
    format: AudioFormat.mp3,
    fileSizeBytes: 1000,
    playCount: 0,
    isFavorite: false,
    importedAt: now,
    updatedAt: now,
  );
}