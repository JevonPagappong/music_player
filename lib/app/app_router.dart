import 'package:go_router/go_router.dart';

import '../features/library/presentation/home_screen.dart';
import '../features/playlists/presentation/playlists_screen.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import 'app_scaffold.dart';

final appRouter = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return AppScaffold(
          location: state.uri.path,
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) {
            return const NoTransitionPage(child: HomeScreen());
          },
        ),
        GoRoute(
          path: '/search',
          pageBuilder: (context, state) {
            return const NoTransitionPage(child: SearchScreen());
          },
        ),
        GoRoute(
          path: '/playlists',
          pageBuilder: (context, state) {
            return const NoTransitionPage(child: PlaylistsScreen());
          },
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) {
            return const NoTransitionPage(child: SettingsScreen());
          },
        ),
      ],
    ),
  ],
);