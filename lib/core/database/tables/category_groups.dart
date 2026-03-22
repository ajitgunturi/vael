import 'package:drift/drift.dart';

import 'families.dart';

/// User-extensible category groups within a family.
///
/// Each category belongs to exactly one group. Groups define the
/// high-level taxonomy (e.g. "Home Expenses", "Investments") and
/// determine which context-sensitive metadata fields appear on
/// the transaction form.
class CategoryGroups extends Table {
  /// Slug identifier, e.g. 'HOME_EXPENSES'.
  TextColumn get id => text()();

  /// Human-readable display name, e.g. 'Home Expenses'.
  TextColumn get name => text()();

  /// Sort order for UI rendering.
  IntColumn get displayOrder => integer().withDefault(const Constant(0))();

  TextColumn get familyId => text().references(Families, #id)();

  @override
  Set<Column> get primaryKey => {id, familyId};
}
