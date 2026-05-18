import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_theme.dart';
import '../../../core/models/lyrics.dart';
import '../application/lyrics_controller_provider.dart';
import '../application/lyrics_state_provider.dart';

Future<void> showEditLyricsSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String songId,
  Lyrics? existingLyrics,
}) async {
  final result = await showDialog<_LyricsEditResult>(
    context: context,
    builder: (context) {
      return _EditLyricsDialog(existingLyrics: existingLyrics);
    },
  );

  if (result == null || result.action == _LyricsEditAction.cancel) {
    return;
  }

  if (result.action == _LyricsEditAction.clear) {
    await ref.read(lyricsControllerProvider).clearLyricsForSong(songId);
  }

  if (result.action == _LyricsEditAction.save) {
    final text = result.text.trim();

    if (text.isEmpty) {
      await ref.read(lyricsControllerProvider).clearLyricsForSong(songId);
    } else {
      await ref.read(lyricsControllerProvider).saveManualLyrics(
            songId: songId,
            plainText: text,
          );
    }
  }

  ref.invalidate(lyricsForSongProvider(songId));

  if (!context.mounted) {
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Lyrics berhasil diperbarui.'),
      backgroundColor: AppTheme.surfaceLight,
    ),
  );
}

class _EditLyricsDialog extends StatefulWidget {
  const _EditLyricsDialog({
    this.existingLyrics,
  });

  final Lyrics? existingLyrics;

  @override
  State<_EditLyricsDialog> createState() => _EditLyricsDialogState();
}

class _EditLyricsDialogState extends State<_EditLyricsDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(
      text: widget.existingLyrics?.plainText ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _cancel() {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).pop(const _LyricsEditResult.cancel());
  }

  void _clear() {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).pop(const _LyricsEditResult.clear());
  }

  void _save() {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).pop(_LyricsEditResult.save(_controller.text));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit lyrics'),
      content: SizedBox(
        width: 520,
        child: TextField(
          controller: _controller,
          autofocus: true,
          minLines: 8,
          maxLines: 14,
          decoration: const InputDecoration(
            hintText: 'Tulis lirik lagu di sini...',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _cancel,
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: _clear,
          child: const Text('Hapus'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}

class _LyricsEditResult {
  const _LyricsEditResult.cancel()
      : action = _LyricsEditAction.cancel,
        text = '';

  const _LyricsEditResult.clear()
      : action = _LyricsEditAction.clear,
        text = '';

  const _LyricsEditResult.save(this.text) : action = _LyricsEditAction.save;

  final _LyricsEditAction action;
  final String text;
}

enum _LyricsEditAction { cancel, clear, save }