import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/app/offline_music_app.dart';

void main() {
  testWidgets('shows Offline Music home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: OfflineMusicApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Offline Music'), findsOneWidget);
    expect(find.text('Quick Access'), findsOneWidget);
    expect(find.text('Recently Added'), findsOneWidget);
    expect(find.text('Import Songs'), findsOneWidget);
  });
}