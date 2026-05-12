import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';

class ManualPlaylistScreen extends StatelessWidget {
  const ManualPlaylistScreen({
    required this.playlistId,
    required this.playlistName,
    super.key,
  });

  final String playlistId;
  final String playlistName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(playlistName),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Playlist ini masih kosong.\nFitur tambah lagu ke playlist akan dibuat berikutnya.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}