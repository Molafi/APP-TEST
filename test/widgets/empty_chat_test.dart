import 'package:flutter_test/flutter_test.dart';
import 'package:plantsense_ai/features/chat/presentation/chat_screen.dart';

import '../mocks/mocks.dart';
import 'test_app.dart';

void main() {
  testWidgets('empty chat shows title and starter chips', (tester) async {
    final overrides = await defaultOverrides();
    await pumpApp(tester, const ChatScreen(), overrides: overrides);

    // Allow the async load to finish.
    await tester.pump(const Duration(milliseconds: 20));

    expect(find.text('Ask your first question'), findsOneWidget);
    expect(find.text('How often should I water my basil?'), findsOneWidget);
  });

  testWidgets('offline/demo banner present in demo mode', (tester) async {
    final overrides = await defaultOverrides();
    await pumpApp(tester, const ChatScreen(), overrides: overrides);
    await tester.pump(const Duration(milliseconds: 20));

    // Demo mode is the default when no dart-defines are supplied.
    expect(find.textContaining('Demo mode'), findsOneWidget);
  });
}
