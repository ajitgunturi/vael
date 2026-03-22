import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/services/category_seeder.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
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

  group('CategorySeeder', () {
    test('seedDefaults inserts all default groups', () async {
      await _seedFamily('fam_a');
      await CategorySeeder.seedDefaults(db, 'fam_a');

      final groups = await (db.select(
        db.categoryGroups,
      )..where((g) => g.familyId.equals('fam_a'))).get();

      expect(groups.length, CategorySeeder.defaultGroups.length);
      expect(groups.length, 12);

      // Verify display order is sequential
      for (int i = 0; i < groups.length; i++) {
        final group = groups.firstWhere((g) => g.displayOrder == i);
        expect(group, isNotNull);
      }
    });

    test('seedDefaults inserts all default categories', () async {
      await _seedFamily('fam_a');
      await CategorySeeder.seedDefaults(db, 'fam_a');

      final categories = await (db.select(
        db.categories,
      )..where((c) => c.familyId.equals('fam_a'))).get();

      expect(categories.length, CategorySeeder.defaultCategories.length);
    });

    test('seedDefaults is idempotent — second call is a no-op', () async {
      await _seedFamily('fam_a');

      await CategorySeeder.seedDefaults(db, 'fam_a');
      final firstCount = await (db.select(
        db.categoryGroups,
      )..where((g) => g.familyId.equals('fam_a'))).get();

      await CategorySeeder.seedDefaults(db, 'fam_a');
      final secondCount = await (db.select(
        db.categoryGroups,
      )..where((g) => g.familyId.equals('fam_a'))).get();

      expect(secondCount.length, firstCount.length);
    });

    test('seedDefaults creates categories in all expected groups', () async {
      await _seedFamily('fam_a');
      await CategorySeeder.seedDefaults(db, 'fam_a');

      final categories = await (db.select(
        db.categories,
      )..where((c) => c.familyId.equals('fam_a'))).get();

      final groupNames = categories.map((c) => c.groupName).toSet();

      // All groups except MISSING should have categories
      expect(groupNames, contains('HOME_EXPENSES'));
      expect(groupNames, contains('LIVING_EXPENSE'));
      expect(groupNames, contains('ESSENTIAL'));
      expect(groupNames, contains('LUXURY_ESSENTIAL'));
      expect(groupNames, contains('LUXURY_NON_ESSENTIAL'));
      expect(groupNames, contains('PHILANTHROPY'));
      expect(groupNames, contains('SELF_IMPROVEMENT'));
      expect(groupNames, contains('INVESTMENTS'));
      expect(groupNames, contains('NON_ESSENTIAL'));
      expect(groupNames, contains('ASSETS'));
      expect(groupNames, contains('LIABILITIES'));
    });

    test('seedDefaults creates both INCOME and EXPENSE categories', () async {
      await _seedFamily('fam_a');
      await CategorySeeder.seedDefaults(db, 'fam_a');

      final categories = await (db.select(
        db.categories,
      )..where((c) => c.familyId.equals('fam_a'))).get();

      final types = categories.map((c) => c.type).toSet();
      expect(types, contains('INCOME'));
      expect(types, contains('EXPENSE'));
    });

    test('seedDefaults works independently per family', () async {
      await _seedFamily('fam_a');
      await _seedFamily('fam_b');

      await CategorySeeder.seedDefaults(db, 'fam_a');
      await CategorySeeder.seedDefaults(db, 'fam_b');

      final groupsA = await (db.select(
        db.categoryGroups,
      )..where((g) => g.familyId.equals('fam_a'))).get();
      final groupsB = await (db.select(
        db.categoryGroups,
      )..where((g) => g.familyId.equals('fam_b'))).get();

      expect(groupsA.length, groupsB.length);
    });

    test('category IDs are deterministic slugs with family prefix', () async {
      await _seedFamily('fam_a');
      await CategorySeeder.seedDefaults(db, 'fam_a');

      final categories = await (db.select(
        db.categories,
      )..where((c) => c.familyId.equals('fam_a'))).get();

      // Find 'Groceries' — ID should end with '_cat_groceries'
      final groceries = categories.firstWhere((c) => c.name == 'Groceries');
      expect(groceries.id, endsWith('_cat_groceries'));

      // Find 'SIP/Mutual Funds' — slug should normalize slashes
      final sip = categories.firstWhere((c) => c.name == 'SIP/Mutual Funds');
      expect(sip.id, endsWith('_cat_sip_mutual_funds'));
    });
  });
}
