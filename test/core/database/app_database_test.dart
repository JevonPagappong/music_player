import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/core/database/app_database.dart';

void main() {
  group('AppDatabase', () {
    test('stores imported song records with MVP defaults', () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final now = DateTime.utc(2026, 5, 12);

      await database.into(database.songs).insert(
            SongsCompanion.insert(
              songId: 'song-1',
              filePath: '/app/music/song-1.mp3',
              originalFileName: 'song-1.mp3',
              title: 'Track One',
              artist: 'Unknown Artist',
              album: 'Unknown Album',
              durationMs: 180000,
              format: 'mp3',
              fileSizeBytes: 1234567,
              importedAt: now,
              updatedAt: now,
            ),
          );

      final songs = await database.select(database.songs).get();

      expect(songs, hasLength(1));
      expect(songs.single.songId, 'song-1');
      expect(songs.single.title, 'Track One');
      expect(songs.single.artist, 'Unknown Artist');
      expect(songs.single.playCount, 0);
      expect(songs.single.isFavorite, isFalse);
      expect(songs.single.syncStatus, 'localOnly');
    });

    test('stores manual playlist membership', () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final now = DateTime.utc(2026, 5, 12);

      await database.into(database.songs).insert(
            SongsCompanion.insert(
              songId: 'song-1',
              filePath: '/app/music/song-1.mp3',
              originalFileName: 'song-1.mp3',
              title: 'Track One',
              artist: 'Artist One',
              album: 'Album One',
              durationMs: 210000,
              format: 'mp3',
              fileSizeBytes: 2000000,
              importedAt: now,
              updatedAt: now,
            ),
          );

      await database.into(database.playlists).insert(
            PlaylistsCompanion.insert(
              playlistId: 'playlist-1',
              name: 'My Playlist',
              type: 'manual',
              createdAt: now,
              updatedAt: now,
            ),
          );

      await database.into(database.playlistSongs).insert(
            PlaylistSongsCompanion.insert(
              playlistId: 'playlist-1',
              songId: 'song-1',
              position: 0,
              addedAt: now,
            ),
          );

      final playlists = await database.select(database.playlists).get();
      final playlistSongs =
          await database.select(database.playlistSongs).get();

      expect(playlists, hasLength(1));
      expect(playlists.single.name, 'My Playlist');
      expect(playlists.single.type, 'manual');

      expect(playlistSongs, hasLength(1));
      expect(playlistSongs.single.playlistId, 'playlist-1');
      expect(playlistSongs.single.songId, 'song-1');
      expect(playlistSongs.single.position, 0);
    });
  });
}