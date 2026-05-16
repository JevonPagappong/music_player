import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';
import '../../../../core/models/song.dart';

class SongTile extends StatelessWidget {
  const SongTile({
    required this.song,
    this.onTap,
    this.onFavoritePressed,
    this.onEditPressed,
    this.onDeletePressed,
    super.key,
  });

  final Song song;
  final VoidCallback? onTap;
  final VoidCallback? onFavoritePressed;
  final VoidCallback? onEditPressed;
  final VoidCallback? onDeletePressed;

  @override
  Widget build(BuildContext context) {
    final duration = Duration(milliseconds: song.durationMs);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: DecoratedBox(
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const SizedBox(
            width: 48,
            height: 48,
            child: Icon(
              Icons.music_note,
              color: AppTheme.primary,
            ),
          ),
        ),
        title: Text(
          song.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          '${song.artist} • ${_formatDuration(duration)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEditPressed != null)
              IconButton(
                tooltip: 'Edit song info',
                onPressed: onEditPressed,
                icon: const Icon(Icons.edit_outlined),
                color: AppTheme.textSecondary,
              ),
            if (onDeletePressed != null)
              IconButton(
                tooltip: 'Delete song',
                onPressed: onDeletePressed,
                icon: const Icon(Icons.delete_outline),
                color: AppTheme.textSecondary,
              ),
            IconButton(
              tooltip: song.isFavorite ? 'Remove favorite' : 'Add favorite',
              onPressed: onFavoritePressed,
              icon: Icon(
                song.isFavorite ? Icons.favorite : Icons.favorite_border,
              ),
              color: song.isFavorite ? AppTheme.primary : AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }
}