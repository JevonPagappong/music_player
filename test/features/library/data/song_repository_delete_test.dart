import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/core/database/app_database.dart';
import 'package:music_player/core/models/audio_format.dart';
import 'package:music_player/core/models/song.dart';
import 'package:music_player/features/lyrics/data/lyrics_repository.dart';
import 'package:music_player/features/library/data/song_repository.dart';
import 'package:music_player/features/playlists/data/playlist_repository.dart';

void main() {
  group('SongRepository deleteSong', () {
    test('deletes song, playlist memberships, and lyrics', () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final songRepository = SongRepository(database);
      final playlistRepository = PlaylistRepository(database);
      final lyricsRepository = LyricsRepository(database);

      final now = DateTime.utc(2026, 5, 12);

      await songRepository.saveSong(
        Song(
          songId: 'song-1',
          filePath: '/music/song-1.mp3',
          originalFileName: 'song-1.mp3',
          title: 'Song One',
          artist: 'Artist One',
          album: 'Album One',
          durationMs: 180000,
          format: AudioFormat.mp3,
          fileSizeBytes: 1000,
          playCount: 0,
          isFavorite: false,
          importedAt: now,
          updatedAt: now,
        ),
      );

      await playlistRepository.createManualPlaylist(
        playlistId: 'playlist-1',
        name: 'My Playlist',
        createdAt: now,
      );

      await playlistRepository.addSongToPlaylist(
        playlistId: 'playlist-1',
        songId: 'song-1',
        position: 0,
        addedAt: now,
      );

      await lyricsRepository.saveManualLyrics(
        lyricsId: 'lyrics-1',
        songId: 'song-1',
        plainText: 'Lyrics',
        updatedAt: now,
      );

      await songRepository.deleteSong('song-1');

      final songs = await songRepository.getAllSongs();
      final playlistSongIds =
          await playlistRepository.getPlaylistSongIds('playlist-1');
      final lyrics = await lyricsRepository.getLyricsForSong('song-1');

      expect(songs, isEmpty);
      expect(playlistSongIds, isEmpty);
      expect(lyrics, isNull);
    });

    test('calculates total storage bytes from library songs', () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final repository = SongRepository(database);
      final now = DateTime.utc(2026, 5, 12);

      await repository.saveSong(
        Song(
          songId: 'song-1',
          filePath: '/music/song-1.mp3',
          originalFileName: 'song-1.mp3',
          title: 'Song One',
          artist: 'Artist One',
          album: 'Album One',
          durationMs: 180000,
          format: AudioFormat.mp3,
          fileSizeBytes: 1000,
          playCount: 0,
          isFavorite: false,
          importedAt: now,
          updatedAt: now,
        ),
      );

      await repository.saveSong(
        Song(
          songId: 'song-2',
          filePath: '/music/song-2.mp3',
          originalFileName: 'song-2.mp3',
          title: 'Song Two',
          artist: 'Artist Two',
          album: 'Album Two',
          durationMs: 180000,
          format: AudioFormat.mp3,
          fileSizeBytes: 2500,
          playCount: 0,
          isFavorite: false,
          importedAt: now,
          updatedAt: now,
        ),
      );

      final totalBytes = await repository.getTotalStorageBytes();

      expect(totalBytes, 3500);
    });
  });
}