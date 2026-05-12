import '../../../core/models/song.dart';
import '../data/song_repository.dart';

class LibraryController {
  const LibraryController({
    required SongRepository repository,
    DateTime Function()? now,
  })  : _repository = repository,
        _now = now ?? DateTime.now;

  final SongRepository _repository;
  final DateTime Function() _now;

  Future<List<Song>> loadSongs() {
    return _repository.getAllSongs();
  }

  Future<List<Song>> searchSongs(String keyword) {
    return _repository.searchSongs(keyword);
  }

  Future<void> setFavorite(String songId, bool isFavorite) {
    return _repository.setFavorite(
      songId,
      isFavorite,
      updatedAt: _now().toUtc(),
    );
  }

  Future<void> recordPlayed(String songId) {
    return _repository.incrementPlayCount(
      songId,
      playedAt: _now().toUtc(),
    );
  }
}