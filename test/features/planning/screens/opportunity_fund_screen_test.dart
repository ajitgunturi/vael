import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vael/core/database/database.dart';
import 'package:vael/features/planning/providers/opportunity_fund_providers.dart';
import 'package:vael/features/planning/screens/opportunity_fund_screen.dart';
import 'package:vael/shared/theme/app_theme.dart';

const _familyId = 'fam_opp';

Account _fakeAccount({
  required String id,
  required String name,
  int balance = 0,
  bool isOpportunityFund = false,
  int? opportunityFundTargetPaise,
}) {
  return Account(
    id: id,
    name: name,
    type: 'savings',
    balance: balance,
    currency: 'INR',
    visibility: 'private',
    sharedWithFamily: true,
    familyId: _familyId,
    userId: 'user_opp',
    isEmergencyFund: false,
    isOpportunityFund: isOpportunityFund,
    opportunityFundTargetPaise: opportunityFundTargetPaise,
  );
}

Widget _buildApp({Account? account}) {
  return ProviderScope(
    overrides: [
      opportunityFundProvider(
        _familyId,
      ).overrideWith((_) => Stream.value(account)),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      home: OpportunityFundScreen(familyId: _familyId),
    ),
  );
}

void main() {
  group('OpportunityFundScreen', () {
    testWidgets('shows empty state when no fund designated', (tester) async {
      await tester.pumpWidget(_buildApp(account: null));
      await tester.pumpAndSettle();

      expect(find.text('No opportunity fund designated'), findsOneWidget);
      expect(find.text('Designate Account'), findsOneWidget);
    });

    testWidgets('shows fund details when designated', (tester) async {
      final account = _fakeAccount(
        id: 'acc_opp',
        name: 'Savings Account',
        balance: 5000000, // Rs 50,000
        isOpportunityFund: true,
        opportunityFundTargetPaise: 10000000, // Rs 1,00,000
      );

      await tester.pumpWidget(_buildApp(account: account));
      await tester.pumpAndSettle();

      expect(find.text('Savings Account'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('Change Account'), findsOneWidget);
      expect(find.text('Remove Designation'), findsOneWidget);
    });
  });
}
