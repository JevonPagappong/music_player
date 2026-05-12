import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_theme.dart';
import '../../application/import_songs_controller_provider.dart';
import '../../application/library_state_provider.dart';

class ImportSongsButton extends ConsumerStatefulWidget {
  const ImportSongsButton({super.key});

  @override
  ConsumerState<ImportSongsButton> createState() => _ImportSongsButtonState();
}

class _ImportSongsButtonState extends ConsumerState<ImportSongsButton> {
  bool _isImporting = false;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: _isImporting ? null : _importSongs,
      icon: _isImporting
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.file_upload_outlined),
      label: Text(_isImporting ? 'Importing...' : 'Import Songs'),
      style: FilledButton.styleFrom(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
    );
  }

  Future<void> _importSongs() async {
    setState(() {
      _isImporting = true;
    });

    try {
      final result = await file_picker.FilePicker.pickFiles(
        allowMultiple: true,
        type: file_picker.FileType.custom,
        allowedExtensions: ['mp3', 'm4a', 'aac'],
      );

      if (!mounted) {
        return;
      }

      if (result == null || result.files.isEmpty) {
        return;
      }

      final importedSongs = await ref
          .read(importSongsControllerProvider)
          .importPickedFiles(result.files);

      ref.invalidate(librarySongsProvider);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${importedSongs.length} lagu berhasil diimport.'),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }
}