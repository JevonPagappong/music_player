enum AudioFormat {
  mp3('mp3'),
  m4a('m4a'),
  aac('aac');

  const AudioFormat(this.extension);

  final String extension;

  static AudioFormat? fromFileName(String fileName) {
    final normalized = fileName.toLowerCase().trim();

    for (final format in AudioFormat.values) {
      if (normalized.endsWith('.${format.extension}')) {
        return format;
      }
    }

    return null;
  }
}