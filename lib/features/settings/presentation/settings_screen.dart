import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        Text(
          'Settings',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 18),
        _SettingsTile(
          icon: Icons.storage,
          title: 'Storage',
          subtitle: 'Total musik dan cache akan ditampilkan nanti.',
        ),
        _SettingsTile(
          icon: Icons.audio_file,
          title: 'Supported formats',
          subtitle: 'MP3, M4A, dan AAC.',
        ),
        _SettingsTile(
          icon: Icons.cloud_off,
          title: 'Offline-first',
          subtitle: 'Mode online akan disiapkan setelah MVP stabil.',
        ),
      ],
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