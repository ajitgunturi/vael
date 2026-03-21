import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/shared/widgets/currency_input.dart';

void main() {
  group('CurrencyInput', () {
    Widget wrap({TextEditingController? controller}) {
      return MaterialApp(
        home: Scaffold(
          body: CurrencyInput(
            label: 'Amount',
            controller: controller,
          ),
        ),
      );
    }

    testWidgets('shows ₹ prefix', (tester) async {
      await tester.pumpWidget(wrap());
      expect(find.text('₹ '), findsOneWidget);
    });

    testWidgets('formats input with Indian commas as user types',
        (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(wrap(controller: controller));
      await tester.pumpAndSettle();

      final field = find.byType(TextFormField);
      await tester.tap(field);

      // Type "1234567" — should format to "12,34,567"
      await tester.enterText(field, '1234567');
      await tester.pumpAndSettle();

      expect(controller.text, '12,34,567');
    });

    testWidgets('formats smaller numbers correctly', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(wrap(controller: controller));
      await tester.pumpAndSettle();

      final field = find.byType(TextFormField);
      await tester.enterText(field, '50000');
      await tester.pumpAndSettle();

      expect(controller.text, '50,000');
    });

    test('toPaise strips commas before parsing', () {
      expect(CurrencyInput.toPaise('12,34,567'), 123456700);
      expect(CurrencyInput.toPaise('50,000'), 5000000);
      expect(CurrencyInput.toPaise('1000'), 100000);
    });

    testWidgets('does not format numbers under 1000', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(wrap(controller: controller));
      await tester.pumpAndSettle();

      final field = find.byType(TextFormField);
      await tester.enterText(field, '999');
      await tester.pumpAndSettle();

      expect(controller.text, '999');
    });
  });
}
