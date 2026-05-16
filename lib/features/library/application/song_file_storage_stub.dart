import 'package:file_picker/file_picker.dart';

class SongFileStorage {
  const SongFileStorage();

  Future<String> savePickedFile(PlatformFile file) async {
    return file.path ?? 'picked-file://${file.name}';
  }
}