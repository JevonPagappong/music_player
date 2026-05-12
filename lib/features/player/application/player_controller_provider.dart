import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'player_controller.dart';

final playerControllerProvider = Provider<PlayerController>((ref) {
  final controller = PlayerController();

  ref.onDispose(controller.dispose);

  return controller;
});