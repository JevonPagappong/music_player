import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class SongFileStorage {
  const SongFileStorage();

  Future<String> savePickedFile(PlatformFile file) async {
    if (kIsWeb) {
      return 'picked-file://${file.name}';
    }

    final sourcePath = file.path;

    if (sourcePath == null || sourcePath.trim().isEmpty) {
      return 'picked-file://${file.name}';
    }

    final appDirectory = await getApplicationDocumentsDirectory();
    final musicDirectory = Directory(
      p.join(appDirectory.path, 'imported_music'),
    );

    if (!await musicDirectory.exists()) {
      await musicDirectory.create(recursive: true);
    }

    final safeFileName = _safeFileName(file.name);
    final targetPath = p.join(
      musicDirectory.path,
      '${DateTime.now().microsecondsSinceEpoch}_$safeFileName',
    );

    final sourceFile = File(sourcePath);
    final copiedFile = await sourceFile.copy(targetPath);

    return copiedFile.path;
  }

  String _safeFileName(String fileName) {
    return fileName
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}