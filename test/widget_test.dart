import 'package:flutter_test/flutter_test.dart';
import 'package:untitled1/main.dart';

void main() {
  testWidgets('Fashion app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FashionApp());

    // Verify that the fashion title exists
    expect(find.text('Discover Style'), findsOneWidget);
  });
}
