import '../models/song.dart';

abstract class AudioEngine {
  Stream<Duration> get positionStream;

  Stream<Duration?> get durationStream;

  Future<void> loadAndPlay({
    required Song song,
    required List<Song> queue,
  });

  Future<void> play();

  Future<void> pause();

  Future<void> seek(Duration position);

  Future<void> stop();

  Future<void> dispose();
}

class NoOpAudioEngine implements AudioEngine {
  const NoOpAudioEngine();

  @override
  Stream<Duration> get positionStream => Stream<Duration>.value(Duration.zero);

  @override
  Stream<Duration?> get durationStream => Stream<Duration?>.value(null);

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
  Future<void> seek(Duration position) async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}