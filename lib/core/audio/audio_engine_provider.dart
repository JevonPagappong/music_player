import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'audio_engine.dart';
import 'just_audio_engine.dart';

final audioEngineProvider = Provider<AudioEngine>((ref) {
  if (kIsWeb || !canUseJustAudioEngine()) {
    const engine = NoOpAudioEngine();
    ref.onDispose(engine.dispose);
    return engine;
  }

  final engine = JustAudioEngine();
  ref.onDispose(engine.dispose);

  return engine;
});