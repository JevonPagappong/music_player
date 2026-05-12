import 'package:flutter/foundation.dart';

import '../../../core/audio/audio_engine.dart';
import '../../../core/models/song.dart';

class PlayerController extends ChangeNotifier {
  PlayerController({
    AudioEngine audioEngine = const NoOpAudioEngine(),
  }) : _audioEngine = audioEngine;

  final AudioEngine _audioEngine;

  Song? _currentSong;
  List<Song> _queue = [];
  bool _isPlaying = false;

  Song? get currentSong => _currentSong;
  List<Song> get queue => List.unmodifiable(_queue);
  bool get isPlaying => _isPlaying;

  Future<void> playSong(
    Song song, {
    required List<Song> queue,
  }) async {
    _queue = queue.isEmpty ? [song] : List<Song>.from(queue);
    _currentSong = song;
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
    _isPlaying = true;
    notifyListeners();

    await _audioEngine.loadAndPlay(
      song: previousSong,
      queue: _queue,
    );
  }

  Future<void> stop() async {
    _isPlaying = false;
    notifyListeners();

    await _audioEngine.stop();
  }

  @override
  void dispose() {
    _audioEngine.dispose();
    super.dispose();
  }
}