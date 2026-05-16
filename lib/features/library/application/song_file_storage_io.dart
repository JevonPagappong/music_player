import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class SongFileStorage {
  const SongFileStorage();

  Future<String> savePickedFile(PlatformFile file) async {
    final sourcePath = file.path;

    if (sourcePath == null || sourcePath.trim().isEmpty) {
      return 'picked-file://${file.name}';
    }

    final appDocuments = await getApplicationDocumentsDirectory();
    final musicDirectory = Directory(p.join(appDocuments.path, 'music'));

    if (!musicDirectory.existsSync()) {
      await musicDirectory.create(recursive: true);
    }

    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final safeName = file.name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final destinationPath = p.join(
      musicDirectory.path,
      '${timestamp}_$safeName',
    );

    final copiedFile = await File(sourcePath).copy(destinationPath);

    return copiedFile.path;
  }
}