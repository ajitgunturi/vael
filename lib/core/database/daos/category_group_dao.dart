import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/category_groups.dart';

part 'category_group_dao.g.dart';

@DriftAccessor(tables: [CategoryGroups])
class CategoryGroupDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryGroupDaoMixin {
  CategoryGroupDao(super.db);

  /// Returns all groups for [familyId], ordered by display order.
  Future<List<CategoryGroup>> getAll(String familyId) {
    return (select(categoryGroups)
          ..where((g) => g.familyId.equals(familyId))
          ..orderBy([(g) => OrderingTerm.asc(g.displayOrder)]))
        .get();
  }

  /// Watches all groups for [familyId], ordered by display order.
  Stream<List<CategoryGroup>> watchAll(String familyId) {
    return (select(categoryGroups)
          ..where((g) => g.familyId.equals(familyId))
          ..orderBy([(g) => OrderingTerm.asc(g.displayOrder)]))
        .watch();
  }

  /// Inserts a new category group.
  Future<int> insertGroup(CategoryGroupsCompanion entry) {
    return into(categoryGroups).insert(entry);
  }

  /// Updates an existing category group.
  Future<bool> updateGroup(CategoryGroupsCompanion entry) {
    return update(categoryGroups).replace(
      CategoryGroupsCompanion(
        id: entry.id,
        name: entry.name,
        displayOrder: entry.displayOrder,
        familyId: entry.familyId,
      ),
    );
  }

  /// Deletes a category group by [id].
  Future<int> deleteGroup(String id) {
    return (delete(categoryGroups)..where((g) => g.id.equals(id))).go();
  }
}
