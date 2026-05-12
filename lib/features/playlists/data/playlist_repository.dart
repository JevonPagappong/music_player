import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

class PlaylistRepository {
  const PlaylistRepository(this._database);

  final AppDatabase _database;

  Future<void> createManualPlaylist({
    required String playlistId,
    required String name,
    required DateTime createdAt,
  }) {
    final createdAtUtc = createdAt.toUtc();

    return _database.into(_database.playlists).insert(
          PlaylistsCompanion.insert(
            playlistId: playlistId,
            name: name.trim(),
            type: 'manual',
            createdAt: createdAtUtc,
            updatedAt: createdAtUtc,
          ),
        );
  }

  Future<List<PlaylistRecord>> getManualPlaylists() {
    final query = _database.select(_database.playlists)
      ..where((table) => table.type.equals('manual'))
      ..orderBy([
        (table) => OrderingTerm.asc(table.name),
      ]);

    return query.get();
  }

  Future<void> renamePlaylist({
    required String playlistId,
    required String name,
    required DateTime updatedAt,
  }) {
    return (_database.update(_database.playlists)
          ..where(
            (table) =>
                table.playlistId.equals(playlistId) &
                table.type.equals('manual'),
          ))
        .write(
      PlaylistsCompanion(
        name: Value(name.trim()),
        updatedAt: Value(updatedAt.toUtc()),
      ),
    );
  }

  Future<void> deleteManualPlaylist(String playlistId) {
    return _database.transaction(() async {
      await (_database.delete(_database.playlistSongs)
            ..where((table) => table.playlistId.equals(playlistId)))
          .go();

      await (_database.delete(_database.playlists)
            ..where(
              (table) =>
                  table.playlistId.equals(playlistId) &
                  table.type.equals('manual'),
            ))
          .go();
    });
  }

  Future<void> addSongToPlaylist({
    required String playlistId,
    required String songId,
    required int position,
    required DateTime addedAt,
  }) {
    return _database.into(_database.playlistSongs).insertOnConflictUpdate(
          PlaylistSongsCompanion.insert(
            playlistId: playlistId,
            songId: songId,
            position: position,
            addedAt: addedAt.toUtc(),
          ),
        );
  }

  Future<void> removeSongFromPlaylist({
    required String playlistId,
    required String songId,
  }) {
    return (_database.delete(_database.playlistSongs)
          ..where(
            (table) =>
                table.playlistId.equals(playlistId) &
                table.songId.equals(songId),
          ))
        .go();
  }

  Future<List<String>> getPlaylistSongIds(String playlistId) async {
    final query = _database.select(_database.playlistSongs)
      ..where((table) => table.playlistId.equals(playlistId))
      ..orderBy([
        (table) => OrderingTerm.asc(table.position),
        (table) => OrderingTerm.asc(table.addedAt),
      ]);

    final rows = await query.get();

    return rows.map((row) => row.songId).toList();
  }
}