import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/database/daos/account_dao.dart';

void main() {
  late AppDatabase db;
  late AccountDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = AccountDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  /// Seeds minimal family + user rows so foreign keys are satisfied.
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

  Future<void> _insertAccount({
    required String id,
    required String familyId,
    String type = 'savings',
    DateTime? deletedAt,
  }) async {
    await db
        .into(db.accounts)
        .insert(
          AccountsCompanion(
            id: Value(id),
            name: Value('Account $id'),
            type: Value(type),
            balance: const Value(0),
            visibility: const Value('shared'),
            familyId: Value(familyId),
            userId: Value('user_$familyId'),
            deletedAt: Value(deletedAt),
          ),
        );
  }

  group('AccountDao', () {
    test('getAll returns only accounts for the given family', () async {
      await _seedFamily('fam_a');
      await _seedFamily('fam_b');

      await _insertAccount(id: 'acc_1', familyId: 'fam_a');
      await _insertAccount(id: 'acc_2', familyId: 'fam_a');
      await _insertAccount(id: 'acc_3', familyId: 'fam_b');

      final results = await dao.getAll('fam_a');

      expect(results, hasLength(2));
      expect(results.map((a) => a.id), containsAll(['acc_1', 'acc_2']));
    });

    test('getAll excludes soft-deleted accounts', () async {
      await _seedFamily('fam_a');

      await _insertAccount(id: 'acc_1', familyId: 'fam_a');
      await _insertAccount(
        id: 'acc_2',
        familyId: 'fam_a',
        deletedAt: DateTime(2025, 6, 1),
      );

      final results = await dao.getAll('fam_a');

      expect(results, hasLength(1));
      expect(results.first.id, 'acc_1');
    });

    test('getByType filters by account type within the family', () async {
      await _seedFamily('fam_a');

      await _insertAccount(id: 'acc_1', familyId: 'fam_a', type: 'savings');
      await _insertAccount(id: 'acc_2', familyId: 'fam_a', type: 'creditCard');
      await _insertAccount(id: 'acc_3', familyId: 'fam_a', type: 'savings');

      final results = await dao.getByType('fam_a', 'savings');

      expect(results, hasLength(2));
      expect(results.every((a) => a.type == 'savings'), isTrue);
    });

    test('getByType excludes soft-deleted accounts', () async {
      await _seedFamily('fam_a');

      await _insertAccount(id: 'acc_1', familyId: 'fam_a', type: 'savings');
      await _insertAccount(
        id: 'acc_2',
        familyId: 'fam_a',
        type: 'savings',
        deletedAt: DateTime(2025, 6, 1),
      );

      final results = await dao.getByType('fam_a', 'savings');

      expect(results, hasLength(1));
    });

    test('getById returns account only when family matches', () async {
      await _seedFamily('fam_a');
      await _seedFamily('fam_b');

      await _insertAccount(id: 'acc_1', familyId: 'fam_a');

      final found = await dao.getById('acc_1', 'fam_a');
      expect(found, isNotNull);
      expect(found!.id, 'acc_1');

      final notFound = await dao.getById('acc_1', 'fam_b');
      expect(notFound, isNull);
    });

    test('getById returns null for soft-deleted account', () async {
      await _seedFamily('fam_a');

      await _insertAccount(
        id: 'acc_1',
        familyId: 'fam_a',
        deletedAt: DateTime(2025, 6, 1),
      );

      final result = await dao.getById('acc_1', 'fam_a');
      expect(result, isNull);
    });

    test('softDelete sets deletedAt without removing the row', () async {
      await _seedFamily('fam_a');
      await _insertAccount(id: 'acc_1', familyId: 'fam_a');

      await dao.softDelete('acc_1');

      // Should not appear in default query
      final results = await dao.getAll('fam_a');
      expect(results, isEmpty);

      // But the row still exists in the raw table
      final raw = await (db.select(
        db.accounts,
      )..where((t) => t.id.equals('acc_1'))).getSingle();
      expect(raw.deletedAt, isNotNull);
    });
  });
}
