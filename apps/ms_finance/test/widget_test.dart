import 'package:flutter_test/flutter_test.dart';
import 'package:ms_finance/main.dart';

void main() {
  testWidgets('MS Finance app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MSFinanceApp());

    // Verify that MS Finance title/app bar appears.
    expect(find.text('MS Finance'), findsWidgets);
  });
}
