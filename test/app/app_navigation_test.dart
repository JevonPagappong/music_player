import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/app/offline_music_app.dart';

void main() {
  testWidgets('navigates between primary app sections', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: OfflineMusicApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Quick Access'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.search_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Cari lagu, artist, atau album'), findsOneWidget);
    expect(
      find.text('Search akan terhubung ke library lokal pada task berikutnya.'),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.queue_music_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Playlists'), findsWidgets);
    expect(find.text('Favorites'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsWidgets);
    expect(find.text('Supported formats'), findsOneWidget);
  });
}