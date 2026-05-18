import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart'
    as audio_metadata_reader;

import 'song_import_preparer.dart';

class SongMetadataReader {
  const SongMetadataReader();

  Future<ImportedSongMetadata> readMetadata({
    required String originalFileName,
    required String filePath,
  }) async {
    final fallbackTitle = _fileNameWithoutExtension(originalFileName);

    if (filePath.trim().isEmpty || filePath.startsWith('picked-file://')) {
      return ImportedSongMetadata(
        title: fallbackTitle,
        artist: '',
        album: '',
        durationMs: 0,
      );
    }

    try {
      final file = File(filePath);

      if (!await file.exists()) {
        return ImportedSongMetadata(
          title: fallbackTitle,
          artist: '',
          album: '',
          durationMs: 0,
        );
      }

      final metadata = audio_metadata_reader.readMetadata(file);

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
    final fallback = fileName.replaceFirst(RegExp(r'\.[^.]+$'), '').trim();

    if (fallback.isEmpty) {
      return 'Unknown Title';
    }

    return fallback;
  }
}