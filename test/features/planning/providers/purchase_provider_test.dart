import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vael/core/database/database.dart';
import 'package:vael/core/providers/database_providers.dart';
import 'package:vael/features/planning/providers/purchase_provider.dart';

const _familyId = 'fam_purch';
const _userId = 'user_purch';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );

    await db
        .into(db.families)
        .insert(
          FamiliesCompanion.insert(
            id: _familyId,
            name: 'Purchase Family',
            createdAt: DateTime(2025),
          ),
        );
    await db
        .into(db.users)
        .insert(
          UsersCompanion.insert(
            id: _userId,
            email: 'purch@family.local',
            displayName: 'Purchase User',
            role: 'admin',
            familyId: _familyId,
          ),
        );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  group('purchaseGoalsProvider', () {
    test('filters goals by purchase category', () async {
      final now = DateTime.now();

      // Insert purchase goal
      await db
          .into(db.goals)
          .insert(
            GoalsCompanion.insert(
              id: 'g_car',
              name: 'Car',
              targetAmount: 1000000000,
              targetDate: DateTime(2027),
              familyId: _familyId,
              goalCategory: const Value('purchase'),
              createdAt: now,
            ),
          );

      // Insert investment goal (should be filtered out)
      await db
          .into(db.goals)
          .insert(
            GoalsCompanion.insert(
              id: 'g_retire',
              name: 'Retirement',
              targetAmount: 5000000000,
              targetDate: DateTime(2050),
              familyId: _familyId,
              goalCategory: const Value('investmentGoal'),
              createdAt: now,
            ),
          );

      final sub = container.listen(
        purchaseGoalsProvider(_familyId),
        (_, __) {},
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final result = sub.read();
      expect(result.value, isNotNull);
      expect(result.value!.length, 1);
      expect(result.value!.first.name, 'Car');
      expect(result.value!.first.goalCategory, 'purchase');
    });
  });

  group('purchaseImpactProvider', () {
    test('computes impact via PurchasePlannerEngine', () {
      final impact = container.read(
        purchaseImpactProvider((
          purchaseAmountPaise: 5000000000,
          downPaymentBp: 2000,
          currentPortfolioPaise: 500000000,
          monthlySavingsPaise: 10000000,
          annualExpensesPaise: 600000000,
          annualReturnRate: 0.10,
          swr: 0.04,
          inflationRate: 0.06,
          yearsToRetirement: 30,
          loanTenureMonths: null,
          loanInterestRate: null,
        )),
      );

      // Down payment = 20% of 50L = 10L, reduces portfolio by 10L
      expect(impact.downPaymentPaise, 1000000000);
      expect(impact.fiYearsAfter, greaterThan(impact.fiYearsBefore));
      expect(impact.fiDelayYears, isPositive);
    });
  });
}
