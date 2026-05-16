import 'package:file_picker/file_picker.dart';

import '../../../core/models/song.dart';
import 'song_import_preparer.dart';
import 'song_import_service.dart';
import 'song_file_storage.dart';
import 'song_metadata_reader.dart';

class ImportSongsController {
  const ImportSongsController({
    required SongImportService importService,
    required SongFileStorage fileStorage,
    required SongMetadataReader metadataReader,
  })  : _importService = importService,
        _fileStorage = fileStorage,
        _metadataReader = metadataReader;

  final SongImportService _importService;
  final SongFileStorage _fileStorage;
  final SongMetadataReader _metadataReader;

  Future<List<Song>> importPickedFiles(List<PlatformFile> files) async {
    final importedSongs = <Song>[];

    for (final file in files) {
      final song = await _importService.importPreparedFile(
        source: ImportSourceFile(
          originalFileName: file.name,
          copiedFilePath: await _fileStorage.savePickedFile(file),
          fileSizeBytes: file.size,
        ),
        metadata: await _metadataReader.readMetadata(file),
      );

      importedSongs.add(song);
    }

    return importedSongs;
  }
}