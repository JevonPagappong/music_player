import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/models/lyrics.dart';
import '../../../core/models/song.dart';

class LyricsRepository {
  const LyricsRepository(this._database);

  final AppDatabase _database;

  Future<Lyrics?> getLyricsForSong(String songId) async {
    final query = _database.select(_database.lyricsEntries)
      ..where((table) => table.songId.equals(songId))
      ..limit(1);

    final record = await query.getSingleOrNull();

    if (record == null) {
      return null;
    }

    return _lyricsFromRecord(record);
  }

  Future<void> saveManualLyrics({
    required String lyricsId,
    required String songId,
    required String plainText,
    required DateTime updatedAt,
  }) {
    return _database.transaction(() async {
      await clearLyricsForSong(songId);

      await _database.into(_database.lyricsEntries).insert(
            LyricsEntriesCompanion.insert(
              lyricsId: lyricsId,
              songId: songId,
              sourceType: LyricsSourceType.manual.name,
              plainText: Value(plainText),
              updatedAt: updatedAt.toUtc(),
            ),
          );
    });
  }

  Future<void> saveLrcLyrics({
    required String lyricsId,
    required String songId,
    required String lrcPath,
    required String timingData,
    required DateTime updatedAt,
  }) {
    return _database.transaction(() async {
      await clearLyricsForSong(songId);

      await _database.into(_database.lyricsEntries).insert(
            LyricsEntriesCompanion.insert(
              lyricsId: lyricsId,
              songId: songId,
              sourceType: LyricsSourceType.lrcFile.name,
              lrcPath: Value(lrcPath),
              timingData: Value(timingData),
              updatedAt: updatedAt.toUtc(),
            ),
          );
    });
  }

  Future<void> clearLyricsForSong(String songId) {
    return (_database.delete(_database.lyricsEntries)
          ..where((table) => table.songId.equals(songId)))
        .go();
  }

  Lyrics _lyricsFromRecord(LyricsRecord record) {
    return Lyrics(
      lyricsId: record.lyricsId,
      songId: record.songId,
      sourceType: _sourceTypeFromName(record.sourceType),
      plainText: record.plainText,
      lrcPath: record.lrcPath,
      timingData: record.timingData,
      updatedAt: record.updatedAt.toUtc(),
      syncStatus: _syncStatusFromName(record.syncStatus),
    );
  }

  LyricsSourceType _sourceTypeFromName(String value) {
    for (final sourceType in LyricsSourceType.values) {
      if (sourceType.name == value) {
        return sourceType;
      }
    }

    return LyricsSourceType.manual;
  }

  SyncStatus _syncStatusFromName(String value) {
    for (final status in SyncStatus.values) {
      if (status.name == value) {
        return status;
      }
    }

    return SyncStatus.localOnly;
  }
}