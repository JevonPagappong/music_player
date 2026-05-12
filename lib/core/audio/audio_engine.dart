import '../models/song.dart';

abstract class AudioEngine {
  Future<void> loadAndPlay({
    required Song song,
    required List<Song> queue,
  });

  Future<void> play();

  Future<void> pause();

  Future<void> stop();

  Future<void> dispose();
}

class NoOpAudioEngine implements AudioEngine {
  const NoOpAudioEngine();

  @override
  Future<void> loadAndPlay({
    required Song song,
    required List<Song> queue,
  }) async {}

  @override
  Future<void> play() async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}