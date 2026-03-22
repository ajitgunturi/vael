import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/financial/dashboard_aggregation.dart';
import 'package:vael/features/accounts/providers/account_ui_providers.dart';
import 'package:vael/features/accounts/screens/account_list_screen.dart';

/// Creates a fake Account object for testing (no real DB needed).
Account _fakeAccount({
  required String id,
  required String name,
  String type = 'savings',
  int balance = 0,
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
    userId: 'user_fam_a',
    deletedAt: null,
  );
}

void main() {
  Widget buildTestApp({
    required AccountGroups groups,
    String familyId = 'fam_a',
  }) {
    return ProviderScope(
      overrides: [
        groupedAccountsProvider(
          familyId,
        ).overrideWith((_) => Stream.value(groups)),
      ],
      child: MaterialApp(home: AccountListScreen(familyId: familyId)),
    );
  }

  group('AccountListScreen', () {
    testWidgets('shows grouped accounts under section headers', (tester) async {
      final groups = AccountGroups(
        banking: [_fakeAccount(id: 'sav', name: 'HDFC Savings')],
        investments: [
          _fakeAccount(id: 'inv', name: 'Zerodha', type: 'investment'),
        ],
        loans: [],
        creditCards: [
          _fakeAccount(id: 'cc', name: 'SBI Credit', type: 'creditCard'),
        ],
      );

      await tester.pumpWidget(buildTestApp(groups: groups));
      await tester.pumpAndSettle();

      expect(find.text('Banking'), findsOneWidget);
      expect(find.text('Investments'), findsOneWidget);
      expect(find.text('Credit Cards'), findsOneWidget);

      expect(find.text('HDFC Savings'), findsOneWidget);
      expect(find.text('SBI Credit'), findsOneWidget);
      expect(find.text('Zerodha'), findsOneWidget);
    });

    testWidgets('formats balance in Indian lakh notation', (tester) async {
      final groups = AccountGroups(
        banking: [
          _fakeAccount(
            id: 'sav',
            name: 'HDFC Savings',
            balance: 32456700, // ₹3,24,567
          ),
        ],
        investments: [],
        loans: [],
        creditCards: [],
      );

      await tester.pumpWidget(buildTestApp(groups: groups));
      await tester.pumpAndSettle();

      expect(find.textContaining('3,24,567'), findsOneWidget);
    });

    testWidgets('shows visibility badge for each account', (tester) async {
      final groups = AccountGroups(
        banking: [
          _fakeAccount(
            id: 'shared',
            name: 'Shared Account',
            visibility: 'shared',
          ),
          _fakeAccount(
            id: 'priv',
            name: 'Private Account',
            visibility: 'hidden',
          ),
        ],
        investments: [],
        loans: [],
        creditCards: [],
      );

      await tester.pumpWidget(buildTestApp(groups: groups));
      await tester.pumpAndSettle();

      expect(find.text('Shared Account'), findsOneWidget);
      expect(find.text('Private Account'), findsOneWidget);
      expect(find.text('Shared'), findsOneWidget);
      expect(find.text('Hidden'), findsOneWidget);
    });

    testWidgets('shows empty state when no accounts exist', (tester) async {
      const groups = AccountGroups(
        banking: [],
        investments: [],
        loans: [],
        creditCards: [],
      );

      await tester.pumpWidget(buildTestApp(groups: groups));
      await tester.pumpAndSettle();

      expect(find.text('No accounts yet'), findsOneWidget);
      expect(find.text('Add Account'), findsOneWidget);
    });

    testWidgets('FAB is present for adding accounts', (tester) async {
      const groups = AccountGroups(
        banking: [],
        investments: [],
        loans: [],
        creditCards: [],
      );

      await tester.pumpWidget(buildTestApp(groups: groups));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('hides empty sections', (tester) async {
      final groups = AccountGroups(
        banking: [_fakeAccount(id: 'sav', name: 'HDFC Savings')],
        investments: [],
        loans: [],
        creditCards: [],
      );

      await tester.pumpWidget(buildTestApp(groups: groups));
      await tester.pumpAndSettle();

      expect(find.text('Banking'), findsOneWidget);
      expect(find.text('Loans'), findsNothing);
      expect(find.text('Investments'), findsNothing);
      expect(find.text('Credit Cards'), findsNothing);
    });
  });
}
