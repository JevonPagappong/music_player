import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../models/song.dart';
import 'audio_engine.dart';

class JustAudioEngine implements AudioEngine {
  JustAudioEngine({
    AudioPlayer? player,
  }) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  @override
  Stream<Duration> get positionStream => _player.positionStream;

  @override
  Stream<Duration?> get durationStream => _player.durationStream;

  @override
  Future<void> loadAndPlay({
    required Song song,
    required List<Song> queue,
  }) async {
    final playbackQueue = queue.isEmpty ? <Song>[song] : List<Song>.from(queue);

    var initialIndex = playbackQueue.indexWhere(
      (queueSong) => queueSong.songId == song.songId,
    );

    if (initialIndex < 0) {
      initialIndex = 0;
    }

    final file = File(song.filePath);
    final exists = await file.exists();

    debugPrint('AUDIO_DEBUG selected_song=${song.title}');
    debugPrint('AUDIO_DEBUG file_path=${song.filePath}');
    debugPrint('AUDIO_DEBUG file_exists=$exists');

    if (!exists) {
      throw StateError('Audio file not found: ${song.filePath}');
    }

    final source = ConcatenatingAudioSource(
      children: playbackQueue.map(_audioSourceForSong).toList(),
    );

    await _player.stop();

    final loadedDuration = await _player.setAudioSource(
      source,
      initialIndex: initialIndex,
      initialPosition: Duration.zero,
    );

    debugPrint('AUDIO_DEBUG loaded_duration=$loadedDuration');
    debugPrint('AUDIO_DEBUG processing_state=${_player.processingState}');

    await _player.play();
  }

  AudioSource _audioSourceForSong(Song song) {
    return AudioSource.uri(
      Uri.file(song.filePath),
      tag: MediaItem(
        id: song.songId,
        title: _fallback(song.title, song.originalFileName),
        artist: _fallback(song.artist, 'Unknown Artist'),
        album: _fallback(song.album, 'Unknown Album'),
        duration: song.durationMs > 0
            ? Duration(milliseconds: song.durationMs)
            : null,
      ),
    );
  }

  String _fallback(String value, String fallback) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return fallback;
    }

    return trimmed;
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
  Future<void> seek(Duration position) {
    return _player.seek(position);
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
  return Platform.isIOS ||
      Platform.isAndroid ||
      Platform.isMacOS ||
      Platform.isWindows;
}