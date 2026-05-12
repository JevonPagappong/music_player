import '../../../core/models/song.dart';
import '../data/song_repository.dart';
import 'song_import_preparer.dart';

class SongImportService {
  const SongImportService({
    required SongImportPreparer preparer,
    required SongRepository repository,
  })  : _preparer = preparer,
        _repository = repository;

  final SongImportPreparer _preparer;
  final SongRepository _repository;

  Future<Song> importPreparedFile({
    required ImportSourceFile source,
    required ImportedSongMetadata metadata,
  }) async {
    final song = _preparer.prepareSong(
      source: source,
      metadata: metadata,
    );

    await _repository.saveSong(song);

    return song;
  }
}