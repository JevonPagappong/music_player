import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart'
    as audio_metadata_reader;
import 'package:file_picker/file_picker.dart';

import 'song_import_preparer.dart';

class SongMetadataReader {
  const SongMetadataReader();

  Future<ImportedSongMetadata> readMetadata(PlatformFile file) async {
    final fallbackTitle = _fileNameWithoutExtension(file.name);
    final path = file.path;

    if (path == null || path.trim().isEmpty) {
      return ImportedSongMetadata(
        title: fallbackTitle,
        artist: '',
        album: '',
        durationMs: 0,
      );
    }

    try {
      final metadata = audio_metadata_reader.readMetadata(File(path));

      return ImportedSongMetadata(
        title: _safeText(metadata.title, fallbackTitle),
        artist: _safeText(metadata.artist, ''),
        album: _safeText(metadata.album, ''),
        durationMs: metadata.duration?.inMilliseconds ?? 0,
      );
    } catch (_) {
      return ImportedSongMetadata(
        title: fallbackTitle,
        artist: '',
        album: '',
        durationMs: 0,
      );
    }
  }

  String _safeText(String? value, String fallback) {
    final trimmed = value?.trim();

    if (trimmed == null || trimmed.isEmpty) {
      return fallback;
    }

    return trimmed;
  }

  String _fileNameWithoutExtension(String fileName) {
    return fileName.replaceFirst(RegExp(r'\.[^.]+$'), '').trim();
  }
}