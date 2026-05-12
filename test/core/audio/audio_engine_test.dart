import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/core/audio/audio_engine.dart';

void main() {
  group('NoOpAudioEngine', () {
    test('all methods complete without throwing', () async {
      const engine = NoOpAudioEngine();

      await engine.play();
      await engine.pause();
      await engine.stop();
      await engine.dispose();
    });
  });
}