import 'package:file_picker/file_picker.dart';

import '../../../core/models/song.dart';
import 'song_import_preparer.dart';
import 'song_import_service.dart';

class ImportSongsController {
  const ImportSongsController({
    required SongImportService importService,
  }) : _importService = importService;

  final SongImportService _importService;

  Future<List<Song>> importPickedFiles(List<PlatformFile> files) async {
    final importedSongs = <Song>[];

    for (final file in files) {
      final song = await _importService.importPreparedFile(
        source: ImportSourceFile(
          originalFileName: file.name,
          copiedFilePath: _copiedFilePathFor(file),
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

  String _copiedFilePathFor(PlatformFile file) {
    if (file.path != null && file.path!.trim().isNotEmpty) {
      return file.path!;
    }

    return 'picked-file://${file.name}';
  }

  String _fileNameWithoutExtension(String fileName) {
    return fileName.replaceFirst(RegExp(r'\.[^.]+$'), '').trim();
  }
}