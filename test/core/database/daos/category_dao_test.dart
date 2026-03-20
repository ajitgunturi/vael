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
    await db.into(db.families).insert(FamiliesCompanion.insert(
          id: familyId,
          name: 'Family $familyId',
          createdAt: DateTime(2025),
        ));
  }

  Future<void> _insertCategory({
    required String id,
    required String familyId,
    required String type,
    String groupName = 'essential',
  }) async {
    await db.into(db.categories).insert(CategoriesCompanion(
          id: Value(id),
          name: Value('Category $id'),
          groupName: Value(groupName),
          type: Value(type),
          familyId: Value(familyId),
        ));
  }

  group('CategoryDao', () {
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
}
