import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/database/daos/investment_holding_dao.dart';

void main() {
  late AppDatabase db;
  late InvestmentHoldingDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = InvestmentHoldingDao(db);
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
  }

  Future<void> _insertHolding({
    required String id,
    required String familyId,
    String bucketType = 'mutualFunds',
    int investedAmount = 1000000,
    int currentValue = 1200000,
  }) async {
    await dao.insertHolding(
      InvestmentHoldingsCompanion(
        id: Value(id),
        name: Value('Bucket $id'),
        bucketType: Value(bucketType),
        investedAmount: Value(investedAmount),
        currentValue: Value(currentValue),
        familyId: Value(familyId),
        userId: Value('user_$familyId'),
        createdAt: Value(DateTime(2026)),
      ),
    );
  }

  group('InvestmentHoldingDao', () {
    test('should insert and retrieve holdings', () async {
      await _seedFamily('f1');
      await _insertHolding(id: 'h1', familyId: 'f1');
      await _insertHolding(id: 'h2', familyId: 'f1', bucketType: 'ppf');

      final all = await dao.getAll('f1');
      expect(all.length, 2);
    });

    test('should get by id', () async {
      await _seedFamily('f1');
      await _insertHolding(id: 'h1', familyId: 'f1');

      final holding = await dao.getById('h1');
      expect(holding, isNotNull);
      expect(holding!.name, 'Bucket h1');
      expect(holding.bucketType, 'mutualFunds');
    });

    test('should return null for non-existent id', () async {
      final holding = await dao.getById('nonexistent');
      expect(holding, isNull);
    });

    test('should filter by family', () async {
      await _seedFamily('f1');
      await _seedFamily('f2');
      await _insertHolding(id: 'h1', familyId: 'f1');
      await _insertHolding(id: 'h2', familyId: 'f2');

      final f1Holdings = await dao.getAll('f1');
      expect(f1Holdings.length, 1);
      expect(f1Holdings[0].id, 'h1');
    });

    test('should delete holding', () async {
      await _seedFamily('f1');
      await _insertHolding(id: 'h1', familyId: 'f1');

      await dao.deleteHolding('h1');
      final all = await dao.getAll('f1');
      expect(all, isEmpty);
    });

    test('should get holdings linked to a goal', () async {
      await _seedFamily('f1');
      // Insert a goal first
      await db
          .into(db.goals)
          .insert(
            GoalsCompanion(
              id: const Value('g1'),
              name: const Value('Retirement'),
              targetAmount: const Value(100000000),
              targetDate: Value(DateTime(2040)),
              familyId: const Value('f1'),
              createdAt: Value(DateTime(2026)),
            ),
          );

      await dao.insertHolding(
        InvestmentHoldingsCompanion(
          id: const Value('h1'),
          name: const Value('Retirement MFs'),
          bucketType: const Value('mutualFunds'),
          investedAmount: const Value(5000000),
          currentValue: const Value(6000000),
          linkedGoalId: const Value('g1'),
          familyId: const Value('f1'),
          userId: const Value('user_f1'),
          createdAt: Value(DateTime(2026)),
        ),
      );

      final goalHoldings = await dao.getByGoal('g1');
      expect(goalHoldings.length, 1);
      expect(goalHoldings[0].name, 'Retirement MFs');
    });
  });
}
