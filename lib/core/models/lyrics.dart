import 'song.dart';

class Lyrics {
  const Lyrics({
    required this.lyricsId,
    required this.songId,
    required this.sourceType,
    required this.updatedAt,
    this.plainText,
    this.lrcPath,
    this.timingData,
    this.syncStatus = SyncStatus.localOnly,
  });

  final String lyricsId;
  final String songId;
  final LyricsSourceType sourceType;
  final String? plainText;
  final String? lrcPath;
  final String? timingData;
  final DateTime updatedAt;
  final SyncStatus syncStatus;
}

enum LyricsSourceType { manual, lrcFile }