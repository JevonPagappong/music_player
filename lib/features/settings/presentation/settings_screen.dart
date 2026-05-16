import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_theme.dart';
import '../../library/application/library_state_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(librarySongsProvider);
    final storageBytesAsync = ref.watch(libraryStorageBytesProvider);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Settings',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 18),
        _AsyncSettingsTile(
          icon: Icons.storage,
          title: 'Storage',
          value: storageBytesAsync.when(
            data: _formatBytes,
            loading: () => 'Menghitung...',
            error: (error, stackTrace) => 'Gagal menghitung storage',
          ),
          subtitle: songsAsync.when(
            data: (songs) => '${songs.length} lagu tersimpan di library lokal.',
            loading: () => 'Memuat jumlah lagu...',
            error: (error, stackTrace) => 'Gagal memuat jumlah lagu.',
          ),
        ),
        const _SettingsTile(
          icon: Icons.audio_file,
          title: 'Supported formats',
          subtitle: 'MP3, M4A, dan AAC.',
        ),
        const _SettingsTile(
          icon: Icons.cloud_off,
          title: 'Offline-first',
          subtitle: 'Mode online akan disiapkan setelah MVP stabil.',
        ),
      ],
    );
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }

    final kb = bytes / 1024;

    if (kb < 1024) {
      return '${kb.toStringAsFixed(1)} KB';
    }

    final mb = kb / 1024;

    if (mb < 1024) {
      return '${mb.toStringAsFixed(1)} MB';
    }

    final gb = mb / 1024;

    return '${gb.toStringAsFixed(2)} GB';
  }
}

class _AsyncSettingsTile extends StatelessWidget {
  const _AsyncSettingsTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary),
        title: Text(
          '$title · $value',
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

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
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