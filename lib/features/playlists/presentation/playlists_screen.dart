import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../app/app_theme.dart';
import '../application/playlist_state_provider.dart';
import '../data/playlist_repository_provider.dart';

class PlaylistsScreen extends ConsumerWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manualPlaylistsAsync = ref.watch(manualPlaylistsProvider);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Playlists',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            IconButton.filled(
              tooltip: 'Create playlist',
              onPressed: () => _showCreatePlaylistDialog(context, ref),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const _PlaylistTile(
          icon: Icons.favorite,
          title: 'Favorites',
          subtitle: 'Lagu yang kamu tandai favorit',
          route: '/playlists/favorites',
        ),
        const _PlaylistTile(
          icon: Icons.new_releases,
          title: 'Recently Added',
          subtitle: 'Lagu yang baru diimport',
          route: '/playlists/recently-added',
        ),
        const _PlaylistTile(
          icon: Icons.trending_up,
          title: 'Most Played',
          subtitle: 'Lagu yang paling sering diputar',
          route: '/playlists/most-played',
        ),
        const SizedBox(height: 20),
        const Text(
          'Manual Playlists',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        manualPlaylistsAsync.when(
          data: (playlists) {
            if (playlists.isEmpty) {
              return const _EmptyManualPlaylistCard();
            }

            return Column(
              children: playlists.map((playlist) {
                final encodedName = Uri.encodeComponent(playlist.name);

                return _PlaylistTile(
                  icon: Icons.queue_music,
                  title: playlist.name,
                  subtitle: 'Playlist manual',
                  route:
                      '/manual-playlist/${playlist.playlistId}/$encodedName',
                );
              }).toList(),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stackTrace) => Text(
            error.toString(),
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      ],
    );
  }

  Future<void> _showCreatePlaylistDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final controller = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        void closeDialog([String? value]) {
          FocusManager.instance.primaryFocus?.unfocus();
          Navigator.of(dialogContext).pop(value);
        }

        return AlertDialog(
          title: const Text('Buat playlist'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Nama playlist',
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: closeDialog,
          ),
          actions: [
            TextButton(
              onPressed: () => closeDialog(),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => closeDialog(controller.text),
              child: const Text('Buat'),
            ),
          ],
        );
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.dispose();
    });

    final trimmedName = name?.trim();

    if (trimmedName == null || trimmedName.isEmpty) {
      return;
    }

    await ref.read(playlistRepositoryProvider).createManualPlaylist(
          playlistId: const Uuid().v4(),
          name: trimmedName,
          createdAt: DateTime.now().toUtc(),
        );

    ref.invalidate(manualPlaylistsProvider);

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Playlist "$trimmedName" dibuat.')),
    );
  }
}

class _PlaylistTile extends StatelessWidget {
  const _PlaylistTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () => context.push(route),
        leading: Icon(icon, color: AppTheme.primary),
        title: Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}

class _EmptyManualPlaylistCard extends StatelessWidget {
  const _EmptyManualPlaylistCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Text(
          'Belum ada playlist manual.\nTap tombol + untuk membuat playlist.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      ),
    );
  }
}