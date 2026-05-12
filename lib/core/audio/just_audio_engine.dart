import 'dart:io';

import 'package:just_audio/just_audio.dart';

import '../models/song.dart';
import 'audio_engine.dart';

class JustAudioEngine implements AudioEngine {
  JustAudioEngine({
    AudioPlayer? player,
  }) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  @override
  Future<void> loadAndPlay({
    required Song song,
    required List<Song> queue,
  }) async {
    await _player.setFilePath(song.filePath);
    await _player.play();
  }

  @override
  Future<void> play() {
    return _player.play();
  }

  @override
  Future<void> pause() {
    return _player.pause();
  }

  @override
  Future<void> stop() {
    return _player.stop();
  }

  @override
  Future<void> dispose() {
    return _player.dispose();
  }
}

bool canUseJustAudioEngine() {
  return Platform.isIOS || Platform.isAndroid || Platform.isMacOS || Platform.isWindows;
}