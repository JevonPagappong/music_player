import 'package:file_picker/file_picker.dart';

import '../../../core/models/song.dart';
import 'song_import_preparer.dart';
import 'song_import_service.dart';
import 'song_file_storage.dart';

class ImportSongsController {
  const ImportSongsController({
    required SongImportService importService,
    required SongFileStorage fileStorage,
  })  : _importService = importService,
        _fileStorage = fileStorage;

  final SongImportService _importService;
  final SongFileStorage _fileStorage;

  Future<List<Song>> importPickedFiles(List<PlatformFile> files) async {
    final importedSongs = <Song>[];

    for (final file in files) {
      final song = await _importService.importPreparedFile(
        source: ImportSourceFile(
          originalFileName: file.name,
          copiedFilePath: await _fileStorage.savePickedFile(file),
          fileSizeBytes: file.size,
        ),
        metadata: ImportedSongMetadata(
          title: _fileNameWithoutExtension(file.name),
          artist: '',
          album: '',
          durationMs: 0,
        ),
      );

      importedSongs.add(song);
    }

    return importedSongs;
  }

  String _fileNameWithoutExtension(String fileName) {
    return fileName.replaceFirst(RegExp(r'\.[^.]+$'), '').trim();
  }
}