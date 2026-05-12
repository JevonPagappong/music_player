import 'package:uuid/uuid.dart';

import '../../../core/models/lyrics.dart';
import '../data/lyrics_repository.dart';

class LyricsController {
  LyricsController({
    required LyricsRepository repository,
    String Function()? idGenerator,
    DateTime Function()? now,
  })  : _repository = repository,
        _idGenerator = idGenerator ?? const Uuid().v4,
        _now = now ?? DateTime.now;

  final LyricsRepository _repository;
  final String Function() _idGenerator;
  final DateTime Function() _now;

  Future<Lyrics?> getLyricsForSong(String songId) {
    return _repository.getLyricsForSong(songId);
  }

  Future<void> saveManualLyrics({
    required String songId,
    required String plainText,
  }) {
    return _repository.saveManualLyrics(
      lyricsId: _idGenerator(),
      songId: songId,
      plainText: plainText.trim(),
      updatedAt: _now().toUtc(),
    );
  }

  Future<void> clearLyricsForSong(String songId) {
    return _repository.clearLyricsForSong(songId);
  }
}