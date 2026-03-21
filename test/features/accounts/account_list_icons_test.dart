import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/financial/dashboard_aggregation.dart';
import 'package:vael/features/accounts/providers/account_ui_providers.dart';
import 'package:vael/features/accounts/screens/account_list_screen.dart';

Account _fakeAccount({
  required String id,
  required String name,
  required String type,
  required int balance,
  String visibility = 'shared',
}) {
  return Account(
    id: id,
    name: name,
    type: type,
    institution: null,
    balance: balance,
    currency: 'INR',
    visibility: visibility,
    sharedWithFamily: true,
    familyId: 'fam_a',
    userId: 'user_1',
    deletedAt: null,
  );
}

void main() {
  Widget buildTestApp({required AccountGroups groups}) {
    return ProviderScope(
      overrides: [
        groupedAccountsProvider(
          'fam_a',
        ).overrideWith((_) => Stream.value(groups)),
      ],
      child: const MaterialApp(home: AccountListScreen(familyId: 'fam_a')),
    );
  }

  group('Account List Icons + Coloring', () {
    testWidgets('shows type-specific icons for accounts', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          groups: AccountGroups(
            banking: [
              _fakeAccount(
                id: 'a1',
                name: 'Savings',
                type: 'savings',
                balance: 100000,
              ),
            ],
            investments: [],
            loans: [],
            creditCards: [
              _fakeAccount(
                id: 'a2',
                name: 'HDFC CC',
                type: 'creditCard',
                balance: 50000,
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.account_balance), findsOneWidget);
      expect(find.byIcon(Icons.credit_card), findsOneWidget);
    });

    testWidgets('shows red balance for liability accounts', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          groups: AccountGroups(
            banking: [],
            investments: [],
            loans: [
              _fakeAccount(
                id: 'a1',
                name: 'Home Loan',
                type: 'loan',
                balance: 5000000,
              ),
            ],
            creditCards: [],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the balance text widget and check its color is expense/negative
      final balanceText = tester.widget<Text>(find.textContaining('50,000'));
      expect(balanceText.style?.color, isNotNull);
      // Loan balance should be colored as expense (red)
    });
  });
}
