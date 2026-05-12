import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'audio_engine.dart';

final audioEngineProvider = Provider<AudioEngine>((ref) {
  const engine = NoOpAudioEngine();

  ref.onDispose(engine.dispose);

  return engine;
});