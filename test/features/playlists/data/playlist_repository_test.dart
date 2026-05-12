import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/core/database/app_database.dart';
import 'package:music_player/features/playlists/data/playlist_repository.dart';

void main() {
  group('PlaylistRepository', () {
    test('creates a manual playlist', () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final repository = PlaylistRepository(database);
      final now = DateTime.utc(2026, 5, 12);

      await repository.createManualPlaylist(
        playlistId: 'playlist-1',
        name: 'Road Trip',
        createdAt: now,
      );

      final playlists = await repository.getManualPlaylists();

      expect(playlists, hasLength(1));
      expect(playlists.single.playlistId, 'playlist-1');
      expect(playlists.single.name, 'Road Trip');
      expect(playlists.single.type, 'manual');
      expect(playlists.single.createdAt.toUtc(), now);
      expect(playlists.single.updatedAt.toUtc(), now);
    });

    test('renames a manual playlist', () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final repository = PlaylistRepository(database);
      final createdAt = DateTime.utc(2026, 5, 12);
      final updatedAt = DateTime.utc(2026, 5, 13);

      await repository.createManualPlaylist(
        playlistId: 'playlist-1',
        name: 'Old Name',
        createdAt: createdAt,
      );

      await repository.renamePlaylist(
        playlistId: 'playlist-1',
        name: 'New Name',
        updatedAt: updatedAt,
      );

      final playlists = await repository.getManualPlaylists();

      expect(playlists.single.name, 'New Name');
      expect(playlists.single.updatedAt.toUtc(), updatedAt);
    });

    test('adds and removes a song from a playlist', () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final repository = PlaylistRepository(database);
      final now = DateTime.utc(2026, 5, 12);

      await repository.createManualPlaylist(
        playlistId: 'playlist-1',
        name: 'Favorites Mix',
        createdAt: now,
      );

      await repository.addSongToPlaylist(
        playlistId: 'playlist-1',
        songId: 'song-1',
        position: 0,
        addedAt: now,
      );

      var songIds = await repository.getPlaylistSongIds('playlist-1');
      expect(songIds, ['song-1']);

      await repository.removeSongFromPlaylist(
        playlistId: 'playlist-1',
        songId: 'song-1',
      );

      songIds = await repository.getPlaylistSongIds('playlist-1');
      expect(songIds, isEmpty);
    });

    test('deletes a manual playlist and its membership rows', () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final repository = PlaylistRepository(database);
      final now = DateTime.utc(2026, 5, 12);

      await repository.createManualPlaylist(
        playlistId: 'playlist-1',
        name: 'Delete Me',
        createdAt: now,
      );

      await repository.addSongToPlaylist(
        playlistId: 'playlist-1',
        songId: 'song-1',
        position: 0,
        addedAt: now,
      );

      await repository.deleteManualPlaylist('playlist-1');

      final playlists = await repository.getManualPlaylists();
      final songIds = await repository.getPlaylistSongIds('playlist-1');

      expect(playlists, isEmpty);
      expect(songIds, isEmpty);
    });
  });
}