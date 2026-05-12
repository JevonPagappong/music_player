import 'package:flutter/material.dart';

import 'app_router.dart';
import 'app_theme.dart';

class OfflineMusicApp extends StatelessWidget {
  const OfflineMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Offline Music',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      routerConfig: appRouter,
    );
  }
}