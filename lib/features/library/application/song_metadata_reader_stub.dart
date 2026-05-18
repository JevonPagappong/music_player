import 'song_import_preparer.dart';

class SongMetadataReader {
  const SongMetadataReader();

  Future<ImportedSongMetadata> readMetadata({
    required String originalFileName,
    required String filePath,
  }) async {
    return ImportedSongMetadata(
      title: _fileNameWithoutExtension(originalFileName),
      artist: '',
      album: '',
      durationMs: 0,
    );
  }

  String _fileNameWithoutExtension(String fileName) {
    final fallback = fileName.replaceFirst(RegExp(r'\.[^.]+$'), '').trim();

    if (fallback.isEmpty) {
      return 'Unknown Title';
    }

    return fallback;
  }
}