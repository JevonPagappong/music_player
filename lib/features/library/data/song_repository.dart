import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/models/audio_format.dart';
import '../../../core/models/song.dart';

class SongRepository {
  const SongRepository(this._database);

  final AppDatabase _database;

  Future<void> saveSong(Song song) {
    return _database.into(_database.songs).insertOnConflictUpdate(
          SongsCompanion.insert(
            songId: song.songId,
            filePath: song.filePath,
            originalFileName: song.originalFileName,
            title: song.title,
            artist: song.artist,
            album: song.album,
            durationMs: song.durationMs,
            format: song.format.extension,
            fileSizeBytes: song.fileSizeBytes,
            artworkPath: Value(song.artworkPath),
            playCount: Value(song.playCount),
            isFavorite: Value(song.isFavorite),
            lastPlayedAt: Value(song.lastPlayedAt?.toUtc()),
            importedAt: song.importedAt.toUtc(),
            updatedAt: song.updatedAt.toUtc(),
            syncStatus: Value(song.syncStatus.name),
          ),
        );
  }

  Future<List<Song>> getAllSongs() async {
    final query = _database.select(_database.songs)
      ..orderBy([
        (table) => OrderingTerm.desc(table.importedAt),
        (table) => OrderingTerm.asc(table.title),
      ]);

    final records = await query.get();

    return records.map(_songFromRecord).toList();
  }

  Future<List<Song>> searchSongs(String keyword) async {
    final normalizedKeyword = keyword.trim();

    if (normalizedKeyword.isEmpty) {
      return getAllSongs();
    }

    final query = _database.select(_database.songs)
      ..where(
        (table) =>
            table.title.contains(normalizedKeyword) |
            table.artist.contains(normalizedKeyword) |
            table.album.contains(normalizedKeyword),
      )
      ..orderBy([
        (table) => OrderingTerm.asc(table.title),
      ]);

    final records = await query.get();

    return records.map(_songFromRecord).toList();
  }

  Future<List<Song>> getFavoriteSongs() async {
    final query = _database.select(_database.songs)
      ..where((table) => table.isFavorite.equals(true))
      ..orderBy([
        (table) => OrderingTerm.asc(table.title),
      ]);

    final records = await query.get();

    return records.map(_songFromRecord).toList();
  }

  Future<List<Song>> getRecentlyAddedSongs({int limit = 50}) async {
    final query = _database.select(_database.songs)
      ..orderBy([
        (table) => OrderingTerm.desc(table.importedAt),
        (table) => OrderingTerm.asc(table.title),
      ])
      ..limit(limit);

    final records = await query.get();

    return records.map(_songFromRecord).toList();
  }

  Future<List<Song>> getMostPlayedSongs({int limit = 50}) async {
    final query = _database.select(_database.songs)
      ..where((table) => table.playCount.isBiggerThanValue(0))
      ..orderBy([
        (table) => OrderingTerm.desc(table.playCount),
        (table) => OrderingTerm.asc(table.title),
      ])
      ..limit(limit);

    final records = await query.get();

    return records.map(_songFromRecord).toList();
  }

  Future<void> updateSongInfo({
    required String songId,
    required String title,
    required String artist,
    required String album,
    required DateTime updatedAt,
  }) {
    return (_database.update(_database.songs)
          ..where((table) => table.songId.equals(songId)))
        .write(
      SongsCompanion(
        title: Value(title.trim()),
        artist: Value(artist.trim()),
        album: Value(album.trim()),
        updatedAt: Value(updatedAt.toUtc()),
      ),
    );
  }

  Future<void> deleteSong(String songId) {
    return _database.transaction(() async {
      await (_database.delete(_database.playlistSongs)
            ..where((table) => table.songId.equals(songId)))
          .go();

      await (_database.delete(_database.lyricsEntries)
            ..where((table) => table.songId.equals(songId)))
          .go();

      await (_database.delete(_database.songs)
            ..where((table) => table.songId.equals(songId)))
          .go();
    });
  }

  Future<int> getTotalStorageBytes() async {
    final songs = await getAllSongs();

    return songs.fold<int>(
      0,
      (total, song) => total + song.fileSizeBytes,
    );
  }

  Future<void> setFavorite(
    String songId,
    bool isFavorite, {
    required DateTime updatedAt,
  }) {
    return (_database.update(_database.songs)
          ..where((table) => table.songId.equals(songId)))
        .write(
      SongsCompanion(
        isFavorite: Value(isFavorite),
        updatedAt: Value(updatedAt.toUtc()),
      ),
    );
  }

  Future<void> incrementPlayCount(
    String songId, {
    required DateTime playedAt,
  }) async {
    final playedAtUtc = playedAt.toUtc();

    final song = await (_database.select(_database.songs)
          ..where((table) => table.songId.equals(songId)))
        .getSingleOrNull();

    if (song == null) {
      return;
    }

    await (_database.update(_database.songs)
          ..where((table) => table.songId.equals(songId)))
        .write(
      SongsCompanion(
        playCount: Value(song.playCount + 1),
        lastPlayedAt: Value(playedAtUtc),
        updatedAt: Value(playedAtUtc),
      ),
    );
  }

  Song _songFromRecord(SongRecord record) {
    return Song(
      songId: record.songId,
      filePath: record.filePath,
      originalFileName: record.originalFileName,
      title: record.title,
      artist: record.artist,
      album: record.album,
      durationMs: record.durationMs,
      format:
          AudioFormat.fromFileName('file.${record.format}') ?? AudioFormat.mp3,
      fileSizeBytes: record.fileSizeBytes,
      artworkPath: record.artworkPath,
      playCount: record.playCount,
      isFavorite: record.isFavorite,
      lastPlayedAt: record.lastPlayedAt?.toUtc(),
      importedAt: record.importedAt.toUtc(),
      updatedAt: record.updatedAt.toUtc(),
      syncStatus: _syncStatusFromName(record.syncStatus),
    );
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