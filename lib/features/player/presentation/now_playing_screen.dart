import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_theme.dart';
import '../application/player_controller_provider.dart';

class NowPlayingScreen extends ConsumerWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(playerControllerProvider);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final song = controller.currentSong;

        if (song == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Now Playing')),
            body: const Center(
              child: Text(
                'Belum ada lagu yang diputar.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Now Playing'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const _CoverArtPlaceholder(),
              const SizedBox(height: 28),
              Text(
                song.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                song.artist,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                song.album,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 28),
              _ProgressPlaceholder(durationMs: song.durationMs),
              const SizedBox(height: 24),
              _PlaybackControls(
                isPlaying: controller.isPlaying,
                onPrevious: controller.previous,
                onPlayPause: controller.togglePlayPause,
                onNext: controller.next,
              ),
              const SizedBox(height: 32),
              const _SectionTitle('Queue'),
              const SizedBox(height: 12),
              ...controller.queue.map(
                (queueSong) => _QueueTile(
                  title: queueSong.title,
                  artist: queueSong.artist,
                  isCurrent: queueSong.songId == song.songId,
                ),
              ),
              const SizedBox(height: 28),
              const _SectionTitle('Lyrics'),
              const SizedBox(height: 12),
              const _LyricsPlaceholder(),
            ],
          ),
        );
      },
    );
  }
}

class _CoverArtPlaceholder extends StatelessWidget {
  const _CoverArtPlaceholder();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 26,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: const Icon(
          Icons.music_note,
          color: AppTheme.primary,
          size: 96,
        ),
      ),
    );
  }
}

class _ProgressPlaceholder extends StatelessWidget {
  const _ProgressPlaceholder({required this.durationMs});

  final int durationMs;

  @override
  Widget build(BuildContext context) {
    final duration = Duration(milliseconds: durationMs);

    return Column(
      children: [
        Slider(
          value: 0,
          onChanged: null,
          min: 0,
          max: duration.inMilliseconds.toDouble().clamp(1, double.infinity),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '0:00',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            Text(
              _formatDuration(duration),
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }
}

class _PlaybackControls extends StatelessWidget {
  const _PlaybackControls({
    required this.isPlaying,
    required this.onPrevious,
    required this.onPlayPause,
    required this.onNext,
  });

  final bool isPlaying;
  final VoidCallback onPrevious;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          tooltip: 'Shuffle',
          onPressed: () {},
          icon: const Icon(Icons.shuffle),
          color: AppTheme.textSecondary,
        ),
        IconButton(
          tooltip: 'Previous',
          onPressed: onPrevious,
          icon: const Icon(Icons.skip_previous),
          color: AppTheme.textPrimary,
          iconSize: 34,
        ),
        IconButton(
          tooltip: isPlaying ? 'Pause' : 'Play',
          onPressed: onPlayPause,
          icon: Icon(
            isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
          ),
          color: AppTheme.primary,
          iconSize: 72,
        ),
        IconButton(
          tooltip: 'Next',
          onPressed: onNext,
          icon: const Icon(Icons.skip_next),
          color: AppTheme.textPrimary,
          iconSize: 34,
        ),
        IconButton(
          tooltip: 'Repeat',
          onPressed: () {},
          icon: const Icon(Icons.repeat),
          color: AppTheme.textSecondary,
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _QueueTile extends StatelessWidget {
  const _QueueTile({
    required this.title,
    required this.artist,
    required this.isCurrent,
  });

  final String title;
  final String artist;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: isCurrent ? AppTheme.surfaceLight : AppTheme.surface,
      child: ListTile(
        leading: Icon(
          isCurrent ? Icons.volume_up : Icons.music_note,
          color: isCurrent ? AppTheme.primary : AppTheme.textSecondary,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isCurrent ? AppTheme.primary : AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          artist,
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
      ),
    );
  }
}

class _LyricsPlaceholder extends StatelessWidget {
  const _LyricsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Text(
          'Lyrics belum tersedia.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      ),
    );
  }
}