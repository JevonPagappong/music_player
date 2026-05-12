import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/audio/audio_engine.dart';
import '../../../core/models/song.dart';

class PlayerController extends ChangeNotifier {
  PlayerController({
    AudioEngine audioEngine = const NoOpAudioEngine(),
  }) : _audioEngine = audioEngine {
    _positionSubscription = _audioEngine.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });

    _durationSubscription = _audioEngine.durationStream.listen((duration) {
      _duration = duration;
      notifyListeners();
    });
  }

  final AudioEngine _audioEngine;

  late final StreamSubscription<Duration> _positionSubscription;
  late final StreamSubscription<Duration?> _durationSubscription;

  Song? _currentSong;
  List<Song> _queue = [];
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration? _duration;

  Song? get currentSong => _currentSong;
  List<Song> get queue => List.unmodifiable(_queue);
  bool get isPlaying => _isPlaying;
  Duration get position => _position;

  Duration get duration {
    final audioDuration = _duration;

    if (audioDuration != null && audioDuration > Duration.zero) {
      return audioDuration;
    }

    final song = _currentSong;

    if (song == null || song.durationMs <= 0) {
      return Duration.zero;
    }

    return Duration(milliseconds: song.durationMs);
  }

  Future<void> playSong(
    Song song, {
    required List<Song> queue,
  }) async {
    _queue = queue.isEmpty ? [song] : List<Song>.from(queue);
    _currentSong = song;
    _position = Duration.zero;
    _duration = song.durationMs > 0 ? Duration(milliseconds: song.durationMs) : null;
    _isPlaying = true;
    notifyListeners();

    await _audioEngine.loadAndPlay(
      song: song,
      queue: _queue,
    );
  }

  Future<void> togglePlayPause() async {
    if (_currentSong == null) {
      return;
    }

    _isPlaying = !_isPlaying;
    notifyListeners();

    if (_isPlaying) {
      await _audioEngine.play();
    } else {
      await _audioEngine.pause();
    }
  }

  Future<void> seek(Duration position) async {
    if (_currentSong == null) {
      return;
    }

    final safePosition = _clampPosition(position);

    _position = safePosition;
    notifyListeners();

    await _audioEngine.seek(safePosition);
  }

  Future<void> next() async {
    final current = _currentSong;

    if (current == null || _queue.isEmpty) {
      return;
    }

    final currentIndex = _queue.indexWhere(
      (song) => song.songId == current.songId,
    );

    if (currentIndex == -1 || currentIndex >= _queue.length - 1) {
      return;
    }

    final nextSong = _queue[currentIndex + 1];

    _currentSong = nextSong;
    _position = Duration.zero;
    _duration =
        nextSong.durationMs > 0 ? Duration(milliseconds: nextSong.durationMs) : null;
    _isPlaying = true;
    notifyListeners();

    await _audioEngine.loadAndPlay(
      song: nextSong,
      queue: _queue,
    );
  }

  Future<void> previous() async {
    final current = _currentSong;

    if (current == null || _queue.isEmpty) {
      return;
    }

    final currentIndex = _queue.indexWhere(
      (song) => song.songId == current.songId,
    );

    if (currentIndex <= 0) {
      return;
    }

    final previousSong = _queue[currentIndex - 1];

    _currentSong = previousSong;
    _position = Duration.zero;
    _duration = previousSong.durationMs > 0
        ? Duration(milliseconds: previousSong.durationMs)
        : null;
    _isPlaying = true;
    notifyListeners();

    await _audioEngine.loadAndPlay(
      song: previousSong,
      queue: _queue,
    );
  }

  Future<void> stop() async {
    _isPlaying = false;
    _position = Duration.zero;
    notifyListeners();

    await _audioEngine.stop();
  }

  Duration _clampPosition(Duration position) {
    final currentDuration = duration;

    if (position < Duration.zero) {
      return Duration.zero;
    }

    if (currentDuration > Duration.zero && position > currentDuration) {
      return currentDuration;
    }

    return position;
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _durationSubscription.cancel();
    _audioEngine.dispose();
    super.dispose();
  }
}