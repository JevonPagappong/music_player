import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/core/audio/audio_engine.dart';
import 'package:music_player/core/models/audio_format.dart';
import 'package:music_player/core/models/song.dart';
import 'package:music_player/features/player/application/player_controller.dart';

void main() {
  group('PlayerController', () {
    test('starts empty', () {
      final engine = FakeAudioEngine();
      final controller = PlayerController(audioEngine: engine);
      addTearDown(controller.dispose);

      expect(controller.currentSong, isNull);
      expect(controller.isPlaying, isFalse);
      expect(controller.queue, isEmpty);
    });

    test('plays a selected song and creates a queue', () async {
      final engine = FakeAudioEngine();
      final controller = PlayerController(audioEngine: engine);
      addTearDown(controller.dispose);

      final song = _song('song-1', 'Track One');

      await controller.playSong(song, queue: [song]);

      expect(controller.currentSong, song);
      expect(controller.queue, [song]);
      expect(controller.isPlaying, isTrue);
      expect(engine.loadedSongs, ['song-1']);
      expect(engine.playCallCount, 0);
    });

    test('toggles play pause when a song is selected', () async {
      final engine = FakeAudioEngine();
      final controller = PlayerController(audioEngine: engine);
      addTearDown(controller.dispose);

      final song = _song('song-1', 'Track One');

      await controller.playSong(song, queue: [song]);
      await controller.togglePlayPause();

      expect(controller.isPlaying, isFalse);
      expect(engine.pauseCallCount, 1);

      await controller.togglePlayPause();

      expect(controller.isPlaying, isTrue);
      expect(engine.playCallCount, 1);
    });

    test('does not toggle play pause without a selected song', () async {
      final engine = FakeAudioEngine();
      final controller = PlayerController(audioEngine: engine);
      addTearDown(controller.dispose);

      await controller.togglePlayPause();

      expect(controller.currentSong, isNull);
      expect(controller.isPlaying, isFalse);
      expect(engine.playCallCount, 0);
      expect(engine.pauseCallCount, 0);
    });

    test('moves to next song in queue', () async {
      final engine = FakeAudioEngine();
      final controller = PlayerController(audioEngine: engine);
      addTearDown(controller.dispose);

      final songOne = _song('song-1', 'Track One');
      final songTwo = _song('song-2', 'Track Two');

      await controller.playSong(songOne, queue: [songOne, songTwo]);
      await controller.next();

      expect(controller.currentSong, songTwo);
      expect(controller.isPlaying, isTrue);
      expect(engine.loadedSongs, ['song-1', 'song-2']);
    });

    test('moves to previous song in queue', () async {
      final engine = FakeAudioEngine();
      final controller = PlayerController(audioEngine: engine);
      addTearDown(controller.dispose);

      final songOne = _song('song-1', 'Track One');
      final songTwo = _song('song-2', 'Track Two');

      await controller.playSong(songTwo, queue: [songOne, songTwo]);
      await controller.previous();

      expect(controller.currentSong, songOne);
      expect(controller.isPlaying, isTrue);
      expect(engine.loadedSongs, ['song-2', 'song-1']);
    });
  });
}

class FakeAudioEngine implements AudioEngine {
  final loadedSongs = <String>[];
  var playCallCount = 0;
  var pauseCallCount = 0;
  var stopCallCount = 0;
  var disposeCallCount = 0;

  @override
  Future<void> loadAndPlay({
    required Song song,
    required List<Song> queue,
  }) async {
    loadedSongs.add(song.songId);
  }

  @override
  Future<void> play() async {
    playCallCount += 1;
  }

  @override
  Future<void> pause() async {
    pauseCallCount += 1;
  }

  @override
  Future<void> stop() async {
    stopCallCount += 1;
  }

  @override
  Future<void> dispose() async {
    disposeCallCount += 1;
  }
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