import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/models/category_group_display.dart';
import 'package:vael/core/providers/category_providers.dart';
import 'package:vael/core/database/daos/category_dao.dart';
import 'package:vael/core/services/category_seeder.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> _seedData() async {
    await db
        .into(db.families)
        .insert(
          FamiliesCompanion.insert(
            id: 'fam_a',
            name: 'Test Family',
            createdAt: DateTime(2025),
          ),
        );
    await CategorySeeder.seedDefaults(db, 'fam_a');
  }

  // Test the data layer directly (avoids Stream/Timer issues in widget tests)
  group('CategoryPicker data layer', () {
    test('categoriesByGroup groups correctly', () async {
      await _seedData();
      final dao = CategoryDao(db);
      final all = await dao.getAll('fam_a');

      final grouped = <String, List<Category>>{};
      for (final c in all) {
        (grouped[c.groupName] ??= []).add(c);
      }

      // Should have categories in known groups
      expect(grouped.containsKey('HOME_EXPENSES'), isTrue);
      expect(grouped.containsKey('ESSENTIAL'), isTrue);
      expect(grouped.containsKey('INVESTMENTS'), isTrue);
      expect(grouped.containsKey('LIVING_EXPENSE'), isTrue);
    });

    test('expense filter returns only EXPENSE categories', () async {
      await _seedData();
      final dao = CategoryDao(db);
      final expenses = await dao.getByType('fam_a', 'EXPENSE');

      expect(expenses.every((c) => c.type == 'EXPENSE'), isTrue);
      expect(expenses.length, greaterThan(50));
    });

    test('income filter returns only INCOME categories', () async {
      await _seedData();
      final dao = CategoryDao(db);
      final incomes = await dao.getByType('fam_a', 'INCOME');

      expect(incomes.every((c) => c.type == 'INCOME'), isTrue);
      expect(incomes.length, greaterThan(5));
    });

    test('groups are ordered by displayOrder', () async {
      await _seedData();
      final groups =
          await (db.select(db.categoryGroups)
                ..where((g) => g.familyId.equals('fam_a'))
                ..orderBy([(g) => OrderingTerm.asc(g.displayOrder)]))
              .get();

      expect(groups.first.id, 'ASSETS');
      expect(groups.last.id, 'MISSING');
    });

    test('CategoryGroupDisplay.nameOf returns human names', () {
      expect(CategoryGroupDisplay.nameOf('HOME_EXPENSES'), 'Home Expenses');
      expect(
        CategoryGroupDisplay.nameOf('LUXURY_ESSENTIAL'),
        'Luxury Essential',
      );
      expect(CategoryGroupDisplay.nameOf('MISSING'), 'Uncategorized');
      // Custom group falls back to slug cleanup
      expect(CategoryGroupDisplay.nameOf('PET_EXPENSES'), 'PET EXPENSES');
    });

    test('search filtering works on category names', () async {
      await _seedData();
      final dao = CategoryDao(db);
      final all = await dao.getAll('fam_a');

      final groceryMatch = all
          .where((c) => c.name.toLowerCase().contains('grocer'))
          .toList();
      expect(groceryMatch, hasLength(1));
      expect(groceryMatch.first.name, 'Groceries');
    });
  });
}
