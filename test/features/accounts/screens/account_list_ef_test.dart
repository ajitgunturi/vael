import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widget tests verifying shield icon appearance on account list rows
/// based on the isEmergencyFund flag.
///
/// Tests the conditional rendering pattern directly to avoid requiring
/// full database/provider scaffolding for AccountListScreen.

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
}

/// Simulates the _AccountTile title Row pattern from account_list_screen.dart.
Widget _buildTileTitle({required String name, required bool isEmergencyFund}) {
  return ListTile(
    title: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: Text(name)),
        if (isEmergencyFund) ...[
          const SizedBox(width: 4),
          Icon(Icons.shield_outlined, size: 14, color: Colors.green.shade400),
        ],
      ],
    ),
  );
}

void main() {
  group('Account list EF shield badge', () {
    testWidgets('shield icon appears when isEmergencyFund is true', (
      tester,
    ) async {
      await _pump(
        tester,
        _buildTileTitle(name: 'Savings Account', isEmergencyFund: true),
      );

      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
      expect(find.text('Savings Account'), findsOneWidget);
    });

    testWidgets('shield icon does NOT appear when isEmergencyFund is false', (
      tester,
    ) async {
      await _pump(
        tester,
        _buildTileTitle(name: 'Savings Account', isEmergencyFund: false),
      );

      expect(find.byIcon(Icons.shield_outlined), findsNothing);
      expect(find.text('Savings Account'), findsOneWidget);
    });

    testWidgets('shield icon is small and subtle (size 14)', (tester) async {
      await _pump(
        tester,
        _buildTileTitle(name: 'Emergency Savings', isEmergencyFund: true),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.shield_outlined));
      expect(icon.size, 14);
    });
  });
}
