import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/import_songs_button.dart';

import '../../../app/app_theme.dart';
import '../application/library_state_provider.dart';
import 'widgets/song_tile.dart';
import '../../player/application/player_controller_provider.dart';
import '../application/library_controller_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(librarySongsProvider);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _GreetingHeader(),
        const SizedBox(height: 16),
        const ImportSongsButton(),
        const SizedBox(height: 24),
        const _SectionTitle('Quick Access'),
        const SizedBox(height: 12),
        const _QuickAccessGrid(),
        const SizedBox(height: 28),
        const _SectionTitle('Your Playlists'),
        const SizedBox(height: 12),
        const _EmptyCard(
          title: 'Belum ada playlist manual',
          subtitle: 'Buat playlist untuk mengelompokkan lagu favoritmu.',
        ),
        const SizedBox(height: 28),
        const _SectionTitle('Recently Added'),
        const SizedBox(height: 12),
        songsAsync.when(
          data: (songs) {
            if (songs.isEmpty) {
              return const _EmptyCard(
                title: 'Belum ada lagu',
                subtitle:
                    'Import lagu MP3, M4A, atau AAC untuk mulai mendengarkan.',
              );
            }

            return Column(
              children: songs
                  .take(5)
                  .map(
                    (song) => SongTile(
                      song: song,
                      onTap: () {
                        ref.read(libraryControllerProvider).recordPlayed(song.songId);
                        ref.read(playerControllerProvider).playSong(
                          song,
                          queue: songs,
                        );
                        ref.invalidate(librarySongsProvider);
                      },
                    ),
                  )
                  .toList(),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stackTrace) => _EmptyCard(
            title: 'Library gagal dimuat',
            subtitle: error.toString(),
          ),
        ),
      ],
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Offline Music',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Musik pribadi kamu, siap diputar offline.',
          style: TextStyle(
            fontSize: 15,
            color: AppTheme.textSecondary,
          ),
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
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: AppTheme.textPrimary,
      ),
    );
  }
}

class _QuickAccessGrid extends StatelessWidget {
  const _QuickAccessGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        _QuickAccessTile(
          icon: Icons.favorite,
          label: 'Favorites',
        ),
        _QuickAccessTile(
          icon: Icons.new_releases,
          label: 'Recently Added',
        ),
        _QuickAccessTile(
          icon: Icons.trending_up,
          label: 'Most Played',
        ),
        _QuickAccessTile(
          icon: Icons.music_note,
          label: 'Imported Songs',
        ),
      ],
    );
  }
}

class _QuickAccessTile extends StatelessWidget {
  const _QuickAccessTile({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}