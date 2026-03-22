import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/database/daos/category_dao.dart';

void main() {
  late AppDatabase db;
  late CategoryDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = CategoryDao(db);
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
  }

  Future<void> _seedUser(String userId, String familyId) async {
    await db
        .into(db.users)
        .insert(
          UsersCompanion.insert(
            id: userId,
            email: '$userId@test.com',
            displayName: 'User $userId',
            role: 'admin',
            familyId: familyId,
          ),
        );
  }

  Future<void> _seedAccount(
    String accountId,
    String familyId,
    String userId,
  ) async {
    await db
        .into(db.accounts)
        .insert(
          AccountsCompanion.insert(
            id: accountId,
            name: 'Account $accountId',
            type: 'savings',
            balance: 0,
            visibility: 'shared',
            familyId: familyId,
            userId: userId,
          ),
        );
  }

  Future<void> _insertCategory({
    required String id,
    required String familyId,
    required String type,
    String groupName = 'ESSENTIAL',
    String? name,
  }) async {
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion(
            id: Value(id),
            name: Value(name ?? 'Category $id'),
            groupName: Value(groupName),
            type: Value(type),
            familyId: Value(familyId),
          ),
        );
  }

  group('CategoryDao — existing tests', () {
    test('getAll returns only categories for the given family', () async {
      await _seedFamily('fam_a');
      await _seedFamily('fam_b');

      await _insertCategory(id: 'cat_1', familyId: 'fam_a', type: 'EXPENSE');
      await _insertCategory(id: 'cat_2', familyId: 'fam_a', type: 'INCOME');
      await _insertCategory(id: 'cat_3', familyId: 'fam_b', type: 'EXPENSE');

      final results = await dao.getAll('fam_a');

      expect(results, hasLength(2));
      expect(results.map((c) => c.id), containsAll(['cat_1', 'cat_2']));
    });

    test('getByType filters by INCOME', () async {
      await _seedFamily('fam_a');

      await _insertCategory(id: 'cat_1', familyId: 'fam_a', type: 'INCOME');
      await _insertCategory(id: 'cat_2', familyId: 'fam_a', type: 'EXPENSE');
      await _insertCategory(id: 'cat_3', familyId: 'fam_a', type: 'INCOME');

      final results = await dao.getByType('fam_a', 'INCOME');

      expect(results, hasLength(2));
      expect(results.every((c) => c.type == 'INCOME'), isTrue);
    });

    test('getByType filters by EXPENSE', () async {
      await _seedFamily('fam_a');

      await _insertCategory(id: 'cat_1', familyId: 'fam_a', type: 'EXPENSE');
      await _insertCategory(id: 'cat_2', familyId: 'fam_a', type: 'INCOME');

      final results = await dao.getByType('fam_a', 'EXPENSE');

      expect(results, hasLength(1));
      expect(results.first.id, 'cat_1');
    });

    test('getByType does not return categories from another family', () async {
      await _seedFamily('fam_a');
      await _seedFamily('fam_b');

      await _insertCategory(id: 'cat_1', familyId: 'fam_a', type: 'EXPENSE');
      await _insertCategory(id: 'cat_2', familyId: 'fam_b', type: 'EXPENSE');

      final results = await dao.getByType('fam_a', 'EXPENSE');

      expect(results, hasLength(1));
      expect(results.first.id, 'cat_1');
    });
  });

  group('CategoryDao — extended CRUD', () {
    test('watchAll emits on insert', () async {
      await _seedFamily('fam_a');

      final stream = dao.watchAll('fam_a');
      expect(await stream.first, isEmpty);

      await _insertCategory(id: 'cat_new', familyId: 'fam_a', type: 'EXPENSE');
      final latest = await stream.first;
      expect(latest, hasLength(1));
    });

    test('getByGroup returns only matching group', () async {
      await _seedFamily('fam_a');
      await _insertCategory(
        id: 'cat_1',
        familyId: 'fam_a',
        type: 'EXPENSE',
        groupName: 'HOME_EXPENSES',
      );
      await _insertCategory(
        id: 'cat_2',
        familyId: 'fam_a',
        type: 'EXPENSE',
        groupName: 'ESSENTIAL',
      );

      final results = await dao.getByGroup('fam_a', 'HOME_EXPENSES');

      expect(results, hasLength(1));
      expect(results.first.id, 'cat_1');
    });

    test('getById returns the category', () async {
      await _seedFamily('fam_a');
      await _insertCategory(
        id: 'cat_find_me',
        familyId: 'fam_a',
        type: 'EXPENSE',
        name: 'Find Me',
      );

      final result = await dao.getById('cat_find_me');

      expect(result, isNotNull);
      expect(result!.name, 'Find Me');
    });

    test('getById returns null for non-existent id', () async {
      final result = await dao.getById('does_not_exist');
      expect(result, isNull);
    });

    test('updateCategory changes name and group', () async {
      await _seedFamily('fam_a');
      await _insertCategory(
        id: 'cat_edit',
        familyId: 'fam_a',
        type: 'EXPENSE',
        groupName: 'ESSENTIAL',
        name: 'Original',
      );

      await dao.updateCategory(
        CategoriesCompanion(
          id: const Value('cat_edit'),
          name: const Value('Updated'),
          groupName: const Value('HOME_EXPENSES'),
          type: const Value('EXPENSE'),
          familyId: const Value('fam_a'),
        ),
      );

      final updated = await dao.getById('cat_edit');
      expect(updated!.name, 'Updated');
      expect(updated.groupName, 'HOME_EXPENSES');
    });

    test('deleteCategory removes the row', () async {
      await _seedFamily('fam_a');
      await _insertCategory(
        id: 'cat_delete',
        familyId: 'fam_a',
        type: 'EXPENSE',
      );

      final deleted = await dao.deleteCategory('cat_delete');
      expect(deleted, 1);

      final result = await dao.getById('cat_delete');
      expect(result, isNull);
    });

    test(
      'hasTransactions returns true when non-deleted transaction references category',
      () async {
        await _seedFamily('fam_a');
        await _seedUser('user_a', 'fam_a');
        await _seedAccount('acc_a', 'fam_a', 'user_a');
        await _insertCategory(
          id: 'cat_used',
          familyId: 'fam_a',
          type: 'EXPENSE',
        );

        await db
            .into(db.transactions)
            .insert(
              TransactionsCompanion.insert(
                id: 'tx_1',
                amount: 10000,
                date: DateTime(2025, 3, 1),
                kind: 'expense',
                familyId: 'fam_a',
                accountId: 'acc_a',
                categoryId: const Value('cat_used'),
              ),
            );

        expect(await dao.hasTransactions('cat_used'), isTrue);
      },
    );

    test(
      'hasTransactions returns false when no transactions reference category',
      () async {
        await _seedFamily('fam_a');
        await _insertCategory(
          id: 'cat_unused',
          familyId: 'fam_a',
          type: 'EXPENSE',
        );

        expect(await dao.hasTransactions('cat_unused'), isFalse);
      },
    );

    test('hasTransactions ignores soft-deleted transactions', () async {
      await _seedFamily('fam_a');
      await _seedUser('user_a', 'fam_a');
      await _seedAccount('acc_a', 'fam_a', 'user_a');
      await _insertCategory(id: 'cat_soft', familyId: 'fam_a', type: 'EXPENSE');

      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: 'tx_deleted',
              amount: 5000,
              date: DateTime(2025, 3, 1),
              kind: 'expense',
              familyId: 'fam_a',
              accountId: 'acc_a',
              categoryId: const Value('cat_soft'),
              deletedAt: Value(DateTime(2025, 3, 2)),
            ),
          );

      expect(await dao.hasTransactions('cat_soft'), isFalse);
    });
  });
}
