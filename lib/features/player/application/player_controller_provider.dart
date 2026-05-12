import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/audio_engine_provider.dart';
import 'player_controller.dart';

final playerControllerProvider = Provider<PlayerController>((ref) {
  final controller = PlayerController(
    audioEngine: ref.watch(audioEngineProvider),
  );

  ref.onDispose(controller.dispose);

  return controller;
});