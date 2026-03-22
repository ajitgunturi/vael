import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/categories.dart';
import '../tables/transactions.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [Categories, Transactions])
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {
  CategoryDao(super.db);

  /// Returns all categories belonging to [familyId].
  Future<List<Category>> getAll(String familyId) {
    return (select(categories)
          ..where((c) => c.familyId.equals(familyId))
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .get();
  }

  /// Watches all categories for [familyId], ordered by name.
  Stream<List<Category>> watchAll(String familyId) {
    return (select(categories)
          ..where((c) => c.familyId.equals(familyId))
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .watch();
  }

  /// Returns categories of the given [type] ('INCOME' or 'EXPENSE') within
  /// [familyId].
  Future<List<Category>> getByType(String familyId, String type) {
    return (select(
      categories,
    )..where((c) => c.familyId.equals(familyId) & c.type.equals(type))).get();
  }

  /// Watches categories of a given [type] for [familyId].
  Stream<List<Category>> watchByType(String familyId, String type) {
    return (select(categories)
          ..where((c) => c.familyId.equals(familyId) & c.type.equals(type))
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .watch();
  }

  /// Returns categories belonging to a specific [groupName] within [familyId].
  Future<List<Category>> getByGroup(String familyId, String groupName) {
    return (select(categories)
          ..where(
            (c) => c.familyId.equals(familyId) & c.groupName.equals(groupName),
          )
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .get();
  }

  /// Watches categories for a specific [groupName] within [familyId].
  Stream<List<Category>> watchByGroup(String familyId, String groupName) {
    return (select(categories)
          ..where(
            (c) => c.familyId.equals(familyId) & c.groupName.equals(groupName),
          )
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .watch();
  }

  /// Returns a single category by [id], or null if not found.
  Future<Category?> getById(String id) {
    return (select(
      categories,
    )..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  /// Inserts a new category row.
  Future<int> insertCategory(CategoriesCompanion entry) {
    return into(categories).insert(entry);
  }

  /// Updates an existing category.
  Future<bool> updateCategory(CategoriesCompanion entry) {
    return update(categories).replace(
      CategoriesCompanion(
        id: entry.id,
        name: entry.name,
        groupName: entry.groupName,
        type: entry.type,
        icon: entry.icon,
        familyId: entry.familyId,
      ),
    );
  }

  /// Deletes a category by [id]. Returns the number of rows deleted.
  Future<int> deleteCategory(String id) {
    return (delete(categories)..where((c) => c.id.equals(id))).go();
  }

  /// Returns true if any non-deleted transaction references [categoryId].
  Future<bool> hasTransactions(String categoryId) async {
    final query = select(transactions)
      ..where((t) => t.categoryId.equals(categoryId) & t.deletedAt.isNull())
      ..limit(1);
    final results = await query.get();
    return results.isNotEmpty;
  }
}
