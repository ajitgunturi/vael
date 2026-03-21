import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/database/daos/budget_dao.dart';

void main() {
  late AppDatabase db;
  late BudgetDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = BudgetDao(db);
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
            name: 'Family',
            createdAt: DateTime(2025),
          ),
        );
  }

  group('BudgetDao', () {
    test('inserts and retrieves budgets for a month', () async {
      await _seedFamily('fam_a');
      await dao.insertBudget(
        BudgetsCompanion(
          id: const Value('b1'),
          familyId: const Value('fam_a'),
          year: const Value(2025),
          month: const Value(3),
          categoryGroup: const Value('ESSENTIAL'),
          limitAmount: const Value(500000),
        ),
      );
      await dao.insertBudget(
        BudgetsCompanion(
          id: const Value('b2'),
          familyId: const Value('fam_a'),
          year: const Value(2025),
          month: const Value(3),
          categoryGroup: const Value('NON_ESSENTIAL'),
          limitAmount: const Value(200000),
        ),
      );

      final results = await dao.getForMonth('fam_a', 2025, 3);
      expect(results, hasLength(2));
      expect(
        results.map((b) => b.categoryGroup),
        containsAll(['ESSENTIAL', 'NON_ESSENTIAL']),
      );
    });

    test('filters by year and month', () async {
      await _seedFamily('fam_a');
      await dao.insertBudget(
        BudgetsCompanion(
          id: const Value('b1'),
          familyId: const Value('fam_a'),
          year: const Value(2025),
          month: const Value(3),
          categoryGroup: const Value('ESSENTIAL'),
          limitAmount: const Value(500000),
        ),
      );
      await dao.insertBudget(
        BudgetsCompanion(
          id: const Value('b2'),
          familyId: const Value('fam_a'),
          year: const Value(2025),
          month: const Value(4),
          categoryGroup: const Value('ESSENTIAL'),
          limitAmount: const Value(600000),
        ),
      );

      final march = await dao.getForMonth('fam_a', 2025, 3);
      expect(march, hasLength(1));
      expect(march.first.limitAmount, 500000);

      final april = await dao.getForMonth('fam_a', 2025, 4);
      expect(april, hasLength(1));
      expect(april.first.limitAmount, 600000);
    });

    test('updates budget limit', () async {
      await _seedFamily('fam_a');
      await dao.insertBudget(
        BudgetsCompanion(
          id: const Value('b1'),
          familyId: const Value('fam_a'),
          year: const Value(2025),
          month: const Value(3),
          categoryGroup: const Value('ESSENTIAL'),
          limitAmount: const Value(500000),
        ),
      );

      await dao.updateLimit('b1', 750000);

      final results = await dao.getForMonth('fam_a', 2025, 3);
      expect(results.first.limitAmount, 750000);
    });

    test('deletes a budget', () async {
      await _seedFamily('fam_a');
      await dao.insertBudget(
        BudgetsCompanion(
          id: const Value('b1'),
          familyId: const Value('fam_a'),
          year: const Value(2025),
          month: const Value(3),
          categoryGroup: const Value('ESSENTIAL'),
          limitAmount: const Value(500000),
        ),
      );

      await dao.deleteBudget('b1');

      final results = await dao.getForMonth('fam_a', 2025, 3);
      expect(results, isEmpty);
    });

    test('isolates by familyId', () async {
      await _seedFamily('fam_a');
      await _seedFamily('fam_b');
      await dao.insertBudget(
        BudgetsCompanion(
          id: const Value('b1'),
          familyId: const Value('fam_a'),
          year: const Value(2025),
          month: const Value(3),
          categoryGroup: const Value('ESSENTIAL'),
          limitAmount: const Value(500000),
        ),
      );
      await dao.insertBudget(
        BudgetsCompanion(
          id: const Value('b2'),
          familyId: const Value('fam_b'),
          year: const Value(2025),
          month: const Value(3),
          categoryGroup: const Value('ESSENTIAL'),
          limitAmount: const Value(300000),
        ),
      );

      final famA = await dao.getForMonth('fam_a', 2025, 3);
      expect(famA, hasLength(1));
      expect(famA.first.limitAmount, 500000);

      final famB = await dao.getForMonth('fam_b', 2025, 3);
      expect(famB, hasLength(1));
      expect(famB.first.limitAmount, 300000);
    });
  });
}
