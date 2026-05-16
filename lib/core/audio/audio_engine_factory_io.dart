import 'audio_engine.dart';
import 'just_audio_engine.dart';

AudioEngine createAudioEngine() {
  if (!canUseJustAudioEngine()) {
    return const NoOpAudioEngine();
  }

  return JustAudioEngine();
}