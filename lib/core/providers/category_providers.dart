import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../database/daos/category_dao.dart';
import '../database/daos/category_group_dao.dart';
import 'database_providers.dart';

/// Derives a [CategoryDao] from the database.
final categoryDaoProvider = Provider<CategoryDao>((ref) {
  return CategoryDao(ref.watch(databaseProvider));
});

/// Derives a [CategoryGroupDao] from the database.
final categoryGroupDaoProvider = Provider<CategoryGroupDao>((ref) {
  return CategoryGroupDao(ref.watch(databaseProvider));
});

/// Watches all category groups for a family, ordered by display order.
final categoryGroupsProvider =
    StreamProvider.family<List<CategoryGroup>, String>((ref, familyId) {
      return ref.watch(categoryGroupDaoProvider).watchAll(familyId);
    });

/// Watches all categories for a family, ordered by name.
final categoriesProvider = StreamProvider.family<List<Category>, String>((
  ref,
  familyId,
) {
  return ref.watch(categoryDaoProvider).watchAll(familyId);
});

/// Watches expense categories for a family.
final expenseCategoriesProvider = StreamProvider.family<List<Category>, String>(
  (ref, familyId) {
    return ref.watch(categoryDaoProvider).watchByType(familyId, 'EXPENSE');
  },
);

/// Watches income categories for a family.
final incomeCategoriesProvider = StreamProvider.family<List<Category>, String>((
  ref,
  familyId,
) {
  return ref.watch(categoryDaoProvider).watchByType(familyId, 'INCOME');
});

/// Watches categories grouped by their group name.
///
/// Returns a map of group ID → list of categories in that group.
final categoriesByGroupProvider =
    StreamProvider.family<Map<String, List<Category>>, String>((ref, familyId) {
      return ref.watch(categoryDaoProvider).watchAll(familyId).map((cats) {
        final grouped = <String, List<Category>>{};
        for (final c in cats) {
          (grouped[c.groupName] ??= []).add(c);
        }
        return grouped;
      });
    });
