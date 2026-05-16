import 'package:file_picker/file_picker.dart';

import 'song_import_preparer.dart';

class SongMetadataReader {
  const SongMetadataReader();

  Future<ImportedSongMetadata> readMetadata(PlatformFile file) async {
    // Versi native metadata reader disiapkan di sini.
    // Untuk sementara tetap fallback aman agar Android/iOS/Web tidak rusak.
    // Setelah API audio_metadata_reader dikonfirmasi, kita isi pembacaan tag asli.
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