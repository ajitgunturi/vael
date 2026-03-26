import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vael/core/database/database.dart';
import 'package:vael/core/financial/decision_modeler.dart';
import 'package:vael/core/models/enums.dart';
import 'package:vael/core/providers/database_providers.dart';
import 'package:vael/features/planning/providers/decision_provider.dart';

const _familyId = 'fam_dec';
const _userId = 'user_dec';

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
            name: 'Decision Family',
            createdAt: DateTime(2025),
          ),
        );
    await db
        .into(db.users)
        .insert(
          UsersCompanion.insert(
            id: _userId,
            email: 'dec@family.local',
            displayName: 'Dec User',
            role: 'admin',
            familyId: _familyId,
          ),
        );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  group('decisionsProvider', () {
    test('streams decisions from DAO', () async {
      final now = DateTime.now();

      await db
          .into(db.decisions)
          .insert(
            DecisionsCompanion.insert(
              id: 'd1',
              userId: _userId,
              familyId: _familyId,
              decisionType: 'jobChange',
              name: 'Switch to BigCorp',
              parameters: '{"newMonthlySalaryPaise": 20000000}',
              createdAt: now,
            ),
          );

      final sub = container.listen(
        decisionsProvider((userId: _userId, familyId: _familyId)),
        (_, __) {},
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final result = sub.read();
      expect(result.value, isNotNull);
      expect(result.value!.length, 1);
      expect(result.value!.first.name, 'Switch to BigCorp');
      expect(result.value!.first.decisionType, 'jobChange');
    });

    test('excludes soft-deleted decisions', () async {
      final now = DateTime.now();

      await db
          .into(db.decisions)
          .insert(
            DecisionsCompanion.insert(
              id: 'd2',
              userId: _userId,
              familyId: _familyId,
              decisionType: 'rentalChange',
              name: 'Move apartments',
              parameters: '{}',
              createdAt: now,
            ),
          );
      await db
          .into(db.decisions)
          .insert(
            DecisionsCompanion(
              id: const Value('d3'),
              userId: const Value(_userId),
              familyId: const Value(_familyId),
              decisionType: const Value('custom'),
              name: const Value('Deleted decision'),
              parameters: const Value('{}'),
              createdAt: Value(now),
              deletedAt: Value(now),
            ),
          );

      final sub = container.listen(
        decisionsProvider((userId: _userId, familyId: _familyId)),
        (_, __) {},
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final result = sub.read();
      expect(result.value, isNotNull);
      expect(result.value!.length, 1);
      expect(result.value!.first.id, 'd2');
    });
  });

  group('decisionImpactProvider', () {
    test('computes impact for given params', () {
      final impact = container.read(
        decisionImpactProvider((
          type: DecisionType.jobChange,
          params: const JobChangeParams(newMonthlySalaryPaise: 20000000),
          currentAge: 30,
          retirementAge: 60,
          currentPortfolioPaise: 500000000,
          monthlySavingsPaise: 10000000,
          annualExpensesPaise: 600000000,
          currentMonthlySalaryPaise: 15000000,
          swr: 0.04,
          inflationRate: 0.06,
          annualReturnRate: 0.10,
        )),
      );

      expect(impact.fiDelayYears, isNegative);
      expect(impact.monthlyCashFlowChangePaise, equals(5000000));
      expect(impact.nwImpactAtMilestoneAges, isNotEmpty);
    });
  });
}
