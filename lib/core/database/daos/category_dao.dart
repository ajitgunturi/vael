import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/categories.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {
  CategoryDao(super.db);

  /// Returns all categories belonging to [familyId].
  Future<List<Category>> getAll(String familyId) {
    return (select(
      categories,
    )..where((c) => c.familyId.equals(familyId))).get();
  }

  /// Returns categories of the given [type] ('INCOME' or 'EXPENSE') within
  /// [familyId].
  Future<List<Category>> getByType(String familyId, String type) {
    return (select(
      categories,
    )..where((c) => c.familyId.equals(familyId) & c.type.equals(type))).get();
  }

  /// Inserts a new category row.
  Future<int> insertCategory(CategoriesCompanion entry) {
    return into(categories).insert(entry);
  }
}
