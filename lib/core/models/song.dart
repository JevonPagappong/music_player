import 'audio_format.dart';

class Song {
  const Song({
    required this.songId,
    required this.filePath,
    required this.originalFileName,
    required this.title,
    required this.artist,
    required this.album,
    required this.durationMs,
    required this.format,
    required this.fileSizeBytes,
    required this.playCount,
    required this.isFavorite,
    required this.importedAt,
    required this.updatedAt,
    this.artworkPath,
    this.lastPlayedAt,
    this.syncStatus = SyncStatus.localOnly,
  });

  final String songId;
  final String filePath;
  final String originalFileName;
  final String title;
  final String artist;
  final String album;
  final int durationMs;
  final AudioFormat format;
  final int fileSizeBytes;
  final String? artworkPath;
  final int playCount;
  final bool isFavorite;
  final DateTime? lastPlayedAt;
  final DateTime importedAt;
  final DateTime updatedAt;
  final SyncStatus syncStatus;
}

enum SyncStatus { localOnly, pendingSync, synced, conflict }