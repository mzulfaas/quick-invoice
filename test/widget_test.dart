import 'package:flutter_test/flutter_test.dart';
import 'package:quick_invoice/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('QuickInvoiceApp smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const QuickInvoiceApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify brand title is displayed
    expect(find.text('QuickInvoice'), findsOneWidget);
  });
}
