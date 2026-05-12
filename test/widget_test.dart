import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/app/offline_music_app.dart';

void main() {
  testWidgets('shows Offline Music app title', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: OfflineMusicApp(),
      ),
    );

    expect(find.text('Offline Music'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}