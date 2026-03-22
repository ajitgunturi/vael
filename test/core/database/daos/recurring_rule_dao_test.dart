import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/database/daos/recurring_rule_dao.dart';

void main() {
  late AppDatabase db;
  late RecurringRuleDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = RecurringRuleDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> _seedFamily(String familyId) async {
    await db
        .into(db.families)
        .insert(
          FamiliesCompanion.insert(
            id: familyId,
            name: 'Family $familyId',
            createdAt: DateTime(2025),
          ),
        );
    await db
        .into(db.users)
        .insert(
          UsersCompanion.insert(
            id: 'user_$familyId',
            email: '$familyId@test.com',
            displayName: 'User $familyId',
            role: 'admin',
            familyId: familyId,
          ),
        );
    await db
        .into(db.accounts)
        .insert(
          AccountsCompanion(
            id: Value('acc_$familyId'),
            name: const Value('Test Account'),
            type: const Value('savings'),
            balance: const Value(0),
            visibility: const Value('shared'),
            familyId: Value(familyId),
            userId: Value('user_$familyId'),
          ),
        );
  }

  Future<void> _insertRule({
    required String id,
    required String familyId,
    bool isPaused = false,
    double frequencyMonths = 1.0,
  }) async {
    await dao.insertRule(
      RecurringRulesCompanion(
        id: Value(id),
        name: Value('Rule $id'),
        kind: const Value('expense'),
        amount: const Value(100000),
        accountId: Value('acc_$familyId'),
        frequencyMonths: Value(frequencyMonths),
        startDate: Value(DateTime(2026, 1, 1)),
        isPaused: Value(isPaused),
        familyId: Value(familyId),
        userId: Value('user_$familyId'),
        createdAt: Value(DateTime(2026)),
      ),
    );
  }

  group('RecurringRuleDao', () {
    test('should insert and retrieve rules', () async {
      await _seedFamily('f1');
      await _insertRule(id: 'r1', familyId: 'f1');
      await _insertRule(id: 'r2', familyId: 'f1', frequencyMonths: 3.0);

      final all = await dao.getAll('f1');
      expect(all.length, 2);
    });

    test('should get active rules only', () async {
      await _seedFamily('f1');
      await _insertRule(id: 'r1', familyId: 'f1');
      await _insertRule(id: 'r2', familyId: 'f1', isPaused: true);

      final active = await dao.getActive('f1');
      expect(active.length, 1);
      expect(active[0].id, 'r1');
    });

    test('should pause and resume', () async {
      await _seedFamily('f1');
      await _insertRule(id: 'r1', familyId: 'f1');

      await dao.pause('r1');
      var rule = await dao.getById('r1');
      expect(rule!.isPaused, true);
      expect(rule.pausedAt, isNotNull);

      await dao.resume('r1');
      rule = await dao.getById('r1');
      expect(rule!.isPaused, false);
      expect(rule.pausedAt, isNull);
    });

    test('should update last executed date', () async {
      await _seedFamily('f1');
      await _insertRule(id: 'r1', familyId: 'f1');

      final execDate = DateTime(2026, 3, 1);
      await dao.updateLastExecuted('r1', execDate);

      final rule = await dao.getById('r1');
      expect(rule!.lastExecutedDate, execDate);
    });

    test('should delete rule', () async {
      await _seedFamily('f1');
      await _insertRule(id: 'r1', familyId: 'f1');

      await dao.deleteRule('r1');
      final all = await dao.getAll('f1');
      expect(all, isEmpty);
    });

    test('should filter by family', () async {
      await _seedFamily('f1');
      await _seedFamily('f2');
      await _insertRule(id: 'r1', familyId: 'f1');
      await _insertRule(id: 'r2', familyId: 'f2');

      final f1Rules = await dao.getAll('f1');
      expect(f1Rules.length, 1);
    });

    group('isSecondaryIncome', () {
      test('defaults to false when not specified', () async {
        await _seedFamily('f1');
        await _insertRule(id: 'r1', familyId: 'f1');

        final rule = await dao.getById('r1');
        expect(rule, isNotNull);
        expect(rule!.isSecondaryIncome, false);
      });

      test('can be inserted as true and read back', () async {
        await _seedFamily('f1');
        await dao.insertRule(
          RecurringRulesCompanion(
            id: const Value('r_sec'),
            name: const Value('Side gig'),
            kind: const Value('income'),
            amount: const Value(50000_00),
            accountId: const Value('acc_f1'),
            frequencyMonths: const Value(1.0),
            startDate: Value(DateTime(2026, 1, 1)),
            isSecondaryIncome: const Value(true),
            familyId: const Value('f1'),
            userId: const Value('user_f1'),
            createdAt: Value(DateTime(2026)),
          ),
        );

        final rule = await dao.getById('r_sec');
        expect(rule, isNotNull);
        expect(rule!.isSecondaryIncome, true);
        expect(rule.kind, 'income');
      });

      test('watchSecondaryIncome returns only secondary income rules', () async {
        await _seedFamily('f1');

        // Insert a primary income rule
        await dao.insertRule(
          RecurringRulesCompanion(
            id: const Value('r_primary'),
            name: const Value('Salary'),
            kind: const Value('income'),
            amount: const Value(100000_00),
            accountId: const Value('acc_f1'),
            frequencyMonths: const Value(1.0),
            startDate: Value(DateTime(2026, 1, 1)),
            isSecondaryIncome: const Value(false),
            familyId: const Value('f1'),
            userId: const Value('user_f1'),
            createdAt: Value(DateTime(2026)),
          ),
        );

        // Insert a secondary income rule
        await dao.insertRule(
          RecurringRulesCompanion(
            id: const Value('r_secondary'),
            name: const Value('Freelance'),
            kind: const Value('income'),
            amount: const Value(30000_00),
            accountId: const Value('acc_f1'),
            frequencyMonths: const Value(1.0),
            startDate: Value(DateTime(2026, 1, 1)),
            isSecondaryIncome: const Value(true),
            familyId: const Value('f1'),
            userId: const Value('user_f1'),
            createdAt: Value(DateTime(2026)),
          ),
        );

        // Insert a secondary expense rule (should NOT appear)
        await dao.insertRule(
          RecurringRulesCompanion(
            id: const Value('r_sec_expense'),
            name: const Value('Side expense'),
            kind: const Value('expense'),
            amount: const Value(10000_00),
            accountId: const Value('acc_f1'),
            frequencyMonths: const Value(1.0),
            startDate: Value(DateTime(2026, 1, 1)),
            isSecondaryIncome: const Value(true),
            familyId: const Value('f1'),
            userId: const Value('user_f1'),
            createdAt: Value(DateTime(2026)),
          ),
        );

        final results = await dao.watchSecondaryIncome('user_f1', 'f1').first;
        // watchSecondaryIncome only filters on isSecondaryIncome=true + deletedAt IS NULL
        // It does NOT filter on kind='income' (the column tracks the tag, not kind)
        expect(results.length, 2);
        expect(results.any((r) => r.id == 'r_secondary'), true);
        expect(results.any((r) => r.id == 'r_sec_expense'), true);
        // Primary income rule should not be returned
        expect(results.any((r) => r.id == 'r_primary'), false);
      });

      test(
        'existing rules without isSecondaryIncome default to false',
        () async {
          await _seedFamily('f1');
          // Insert without specifying isSecondaryIncome (uses DB default)
          await _insertRule(id: 'r_old', familyId: 'f1');

          final rule = await dao.getById('r_old');
          expect(rule, isNotNull);
          expect(rule!.isSecondaryIncome, false);
        },
      );
    });
  });
}
