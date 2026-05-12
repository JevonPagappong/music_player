import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/core/errors/app_error.dart';
import 'package:music_player/core/models/audio_format.dart';
import 'package:music_player/features/library/application/song_import_preparer.dart';

void main() {
  group('SongImportPreparer', () {
    test('creates a song draft for a supported mp3 file', () {
      final preparer = SongImportPreparer(
        idGenerator: () => 'song-1',
        now: () => DateTime.utc(2026, 5, 12),
      );

      final song = preparer.prepareSong(
        source: const ImportSourceFile(
          originalFileName: 'track.mp3',
          copiedFilePath: '/app/music/song-1.mp3',
          fileSizeBytes: 123456,
        ),
        metadata: const ImportedSongMetadata(
          title: 'Track Title',
          artist: 'Artist Name',
          album: 'Album Name',
          durationMs: 180000,
        ),
      );

      expect(song.songId, 'song-1');
      expect(song.originalFileName, 'track.mp3');
      expect(song.filePath, '/app/music/song-1.mp3');
      expect(song.title, 'Track Title');
      expect(song.artist, 'Artist Name');
      expect(song.album, 'Album Name');
      expect(song.durationMs, 180000);
      expect(song.format, AudioFormat.mp3);
      expect(song.fileSizeBytes, 123456);
      expect(song.playCount, 0);
      expect(song.isFavorite, isFalse);
      expect(song.importedAt, DateTime.utc(2026, 5, 12));
      expect(song.updatedAt, DateTime.utc(2026, 5, 12));
    });

    test('uses safe fallback metadata when metadata is empty', () {
      final preparer = SongImportPreparer(
        idGenerator: () => 'song-1',
        now: () => DateTime.utc(2026, 5, 12),
      );

      final song = preparer.prepareSong(
        source: const ImportSourceFile(
          originalFileName: 'my favorite song.m4a',
          copiedFilePath: '/app/music/song-1.m4a',
          fileSizeBytes: 789,
        ),
        metadata: const ImportedSongMetadata(
          title: '',
          artist: '',
          album: '',
          durationMs: 0,
        ),
      );

      expect(song.title, 'my favorite song');
      expect(song.artist, 'Unknown Artist');
      expect(song.album, 'Unknown Album');
      expect(song.durationMs, 0);
      expect(song.format, AudioFormat.m4a);
    });

    test('trims metadata values before saving', () {
      final preparer = SongImportPreparer(
        idGenerator: () => 'song-1',
        now: () => DateTime.utc(2026, 5, 12),
      );

      final song = preparer.prepareSong(
        source: const ImportSourceFile(
          originalFileName: 'track.aac',
          copiedFilePath: '/app/music/song-1.aac',
          fileSizeBytes: 100,
        ),
        metadata: const ImportedSongMetadata(
          title: '  Title  ',
          artist: '  Artist  ',
          album: '  Album  ',
          durationMs: 90000,
        ),
      );

      expect(song.title, 'Title');
      expect(song.artist, 'Artist');
      expect(song.album, 'Album');
      expect(song.format, AudioFormat.aac);
    });

    test('throws unsupported format error for unsupported audio file', () {
      final preparer = SongImportPreparer(
        idGenerator: () => 'song-1',
        now: () => DateTime.utc(2026, 5, 12),
      );

      expect(
        () => preparer.prepareSong(
          source: const ImportSourceFile(
            originalFileName: 'track.flac',
            copiedFilePath: '/app/music/song-1.flac',
            fileSizeBytes: 100,
          ),
          metadata: const ImportedSongMetadata.empty(),
        ),
        throwsA(isA<UnsupportedAudioFormatError>()),
      );
    });
  });
}