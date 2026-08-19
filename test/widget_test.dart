import 'package:flutter_test/flutter_test.dart';
import 'package:swim_tracker/main.dart';

void main() {
  testWidgets('AquaMind loads', (WidgetTester tester) async {
    await tester.pumpWidget(const AquaMindAI());

    expect(find.text('AquaMind 🌊'), findsOneWidget);
  });
}
