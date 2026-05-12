import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';

class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        Text(
          'Playlists',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 18),
        _PlaylistTile(
          icon: Icons.favorite,
          title: 'Favorites',
          subtitle: 'Lagu yang kamu tandai favorit',
        ),
        _PlaylistTile(
          icon: Icons.new_releases,
          title: 'Recently Added',
          subtitle: 'Lagu yang baru diimport',
        ),
        _PlaylistTile(
          icon: Icons.trending_up,
          title: 'Most Played',
          subtitle: 'Lagu yang paling sering diputar',
        ),
      ],
    );
  }
}

class _PlaylistTile extends StatelessWidget {
  const _PlaylistTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
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
      ),
    );
  }
}