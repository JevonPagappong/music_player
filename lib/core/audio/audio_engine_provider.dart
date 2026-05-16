import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'audio_engine.dart';
import 'audio_engine_factory.dart';

final audioEngineProvider = Provider<AudioEngine>((ref) {
  final engine = createAudioEngine();

  ref.onDispose(engine.dispose);

  return engine;
});