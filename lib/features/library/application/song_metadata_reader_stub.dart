import 'package:file_picker/file_picker.dart';

import 'song_import_preparer.dart';

class SongMetadataReader {
  const SongMetadataReader();

  Future<ImportedSongMetadata> readMetadata(PlatformFile file) async {
    return ImportedSongMetadata(
      title: _fileNameWithoutExtension(file.name),
      artist: '',
      album: '',
      durationMs: 0,
    );
  }

  String _fileNameWithoutExtension(String fileName) {
    return fileName.replaceFirst(RegExp(r'\.[^.]+$'), '').trim();
  }
}