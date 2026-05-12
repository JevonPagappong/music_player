import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/core/models/audio_format.dart';

void main() {
  group('AudioFormat', () {
    test('accepts supported MVP extensions case-insensitively', () {
      expect(AudioFormat.fromFileName('song.mp3'), AudioFormat.mp3);
      expect(AudioFormat.fromFileName('song.M4A'), AudioFormat.m4a);
      expect(AudioFormat.fromFileName('song.AAC'), AudioFormat.aac);
    });

    test('rejects unsupported extensions', () {
      expect(AudioFormat.fromFileName('song.flac'), isNull);
      expect(AudioFormat.fromFileName('song.wav'), isNull);
      expect(AudioFormat.fromFileName('song'), isNull);
    });
  });
}