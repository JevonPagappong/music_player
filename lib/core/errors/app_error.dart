sealed class AppError implements Exception {
  const AppError(this.message);

  final String message;

  @override
  String toString() => message;
}

class UnsupportedAudioFormatError extends AppError {
  const UnsupportedAudioFormatError()
      : super('Format file belum didukung. Gunakan MP3, M4A, atau AAC.');
}

class ImportCopyFailedError extends AppError {
  const ImportCopyFailedError()
      : super('Lagu gagal diimpor. Coba pilih ulang file dari Files app.');
}

class PlaybackFileUnreadableError extends AppError {
  const PlaybackFileUnreadableError()
      : super('File lagu tidak bisa diputar.');
}

class InvalidLyricsFileError extends AppError {
  const InvalidLyricsFileError()
      : super(
          'File lyrics tidak bisa dibaca. '
          'Kamu masih bisa menambahkan lirik manual.',
        );
}