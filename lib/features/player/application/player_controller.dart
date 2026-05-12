import 'package:flutter/foundation.dart';

import '../../../core/models/song.dart';

class PlayerController extends ChangeNotifier {
  Song? _currentSong;
  List<Song> _queue = [];
  bool _isPlaying = false;

  Song? get currentSong => _currentSong;
  List<Song> get queue => List.unmodifiable(_queue);
  bool get isPlaying => _isPlaying;

  void playSong(
    Song song, {
    required List<Song> queue,
  }) {
    _queue = queue.isEmpty ? [song] : List<Song>.from(queue);
    _currentSong = song;
    _isPlaying = true;
    notifyListeners();
  }

  void togglePlayPause() {
    if (_currentSong == null) {
      return;
    }

    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void next() {
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

    _currentSong = _queue[currentIndex + 1];
    _isPlaying = true;
    notifyListeners();
  }

  void previous() {
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

    _currentSong = _queue[currentIndex - 1];
    _isPlaying = true;
    notifyListeners();
  }

  void stop() {
    _isPlaying = false;
    notifyListeners();
  }
}