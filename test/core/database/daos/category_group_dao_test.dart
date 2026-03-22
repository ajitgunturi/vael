import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/database/daos/category_group_dao.dart';

void main() {
  late AppDatabase db;
  late CategoryGroupDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = CategoryGroupDao(db);
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

  Future<void> _insertGroup({
    required String id,
    required String name,
    required String familyId,
    int displayOrder = 0,
  }) async {
    await dao.insertGroup(
      CategoryGroupsCompanion(
        id: Value(id),
        name: Value(name),
        displayOrder: Value(displayOrder),
        familyId: Value(familyId),
      ),
    );
  }

  group('CategoryGroupDao', () {
    test(
      'getAll returns groups for the given family ordered by displayOrder',
      () async {
        await _seedFamily('fam_a');
        await _insertGroup(
          id: 'ESSENTIAL',
          name: 'Essential',
          familyId: 'fam_a',
          displayOrder: 2,
        );
        await _insertGroup(
          id: 'HOME_EXPENSES',
          name: 'Home Expenses',
          familyId: 'fam_a',
          displayOrder: 1,
        );

        final results = await dao.getAll('fam_a');

        expect(results, hasLength(2));
        expect(results.first.id, 'HOME_EXPENSES');
        expect(results.last.id, 'ESSENTIAL');
      },
    );

    test('getAll does not return groups from another family', () async {
      await _seedFamily('fam_a');
      await _seedFamily('fam_b');

      await _insertGroup(id: 'G1', name: 'Group 1', familyId: 'fam_a');
      await _insertGroup(id: 'G2', name: 'Group 2', familyId: 'fam_b');

      final results = await dao.getAll('fam_a');

      expect(results, hasLength(1));
      expect(results.first.id, 'G1');
    });

    test('watchAll emits on insert', () async {
      await _seedFamily('fam_a');

      final stream = dao.watchAll('fam_a');

      // First emission: empty
      expect(await stream.first, isEmpty);

      await _insertGroup(id: 'NEW', name: 'New Group', familyId: 'fam_a');

      // After insert, stream re-emits
      final latest = await stream.first;
      expect(latest, hasLength(1));
      expect(latest.first.name, 'New Group');
    });

    test('deleteGroup removes the group', () async {
      await _seedFamily('fam_a');
      await _insertGroup(id: 'TO_DELETE', name: 'Delete Me', familyId: 'fam_a');

      final deleted = await dao.deleteGroup('TO_DELETE');
      expect(deleted, 1);

      final results = await dao.getAll('fam_a');
      expect(results, isEmpty);
    });

    test('updateGroup changes name and displayOrder', () async {
      await _seedFamily('fam_a');
      await _insertGroup(
        id: 'EDIT_ME',
        name: 'Original',
        familyId: 'fam_a',
        displayOrder: 0,
      );

      await dao.updateGroup(
        CategoryGroupsCompanion(
          id: const Value('EDIT_ME'),
          name: const Value('Updated'),
          displayOrder: const Value(5),
          familyId: const Value('fam_a'),
        ),
      );

      final results = await dao.getAll('fam_a');
      expect(results.first.name, 'Updated');
      expect(results.first.displayOrder, 5);
    });
  });
}
