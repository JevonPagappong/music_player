import 'package:uuid/uuid.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/models/audio_format.dart';
import '../../../core/models/song.dart';

typedef IdGenerator = String Function();
typedef Clock = DateTime Function();

class SongImportPreparer {
  SongImportPreparer({
    IdGenerator? idGenerator,
    Clock? now,
  })  : _idGenerator = idGenerator ?? const Uuid().v4,
        _now = now ?? DateTime.now;

  final IdGenerator _idGenerator;
  final Clock _now;

  Song prepareSong({
    required ImportSourceFile source,
    required ImportedSongMetadata metadata,
  }) {
    final format = AudioFormat.fromFileName(source.originalFileName);

    if (format == null) {
      throw const UnsupportedAudioFormatError();
    }

    final songId = _idGenerator();
    final timestamp = _now().toUtc();

    return Song(
      songId: songId,
      filePath: source.copiedFilePath,
      originalFileName: source.originalFileName,
      title: _fallbackTitle(source.originalFileName, metadata.title),
      artist: _fallbackText(metadata.artist, 'Unknown Artist'),
      album: _fallbackText(metadata.album, 'Unknown Album'),
      durationMs: metadata.durationMs,
      format: format,
      fileSizeBytes: source.fileSizeBytes,
      playCount: 0,
      isFavorite: false,
      importedAt: timestamp,
      updatedAt: timestamp,
    );
  }

  String _fallbackTitle(String fileName, String metadataTitle) {
    final trimmedTitle = metadataTitle.trim();

    if (trimmedTitle.isNotEmpty) {
      return trimmedTitle;
    }

    final nameWithoutExtension = fileName.replaceFirst(
      RegExp(r'\.[^.]+$'),
      '',
    );

    final fallback = nameWithoutExtension.trim();

    if (fallback.isEmpty) {
      return 'Unknown Title';
    }

    return fallback;
  }

  String _fallbackText(String value, String fallback) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return fallback;
    }

    return trimmed;
  }
}

class ImportSourceFile {
  const ImportSourceFile({
    required this.originalFileName,
    required this.copiedFilePath,
    required this.fileSizeBytes,
  });

  final String originalFileName;
  final String copiedFilePath;
  final int fileSizeBytes;
}

class ImportedSongMetadata {
  const ImportedSongMetadata({
    required this.title,
    required this.artist,
    required this.album,
    required this.durationMs,
  });

  const ImportedSongMetadata.empty()
      : title = '',
        artist = '',
        album = '',
        durationMs = 0;

  final String title;
  final String artist;
  final String album;
  final int durationMs;
}