import 'package:drift/drift.dart';

import 'families.dart';
import 'life_profiles.dart';

/// Persists custom and computed net-worth milestone targets per life profile.
class NetWorthMilestones extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get familyId => text().references(Families, #id)();
  TextColumn get lifeProfileId => text().references(LifeProfiles, #id)();
  IntColumn get targetAge => integer()();
  IntColumn get targetAmountPaise => integer()();
  BoolColumn get isCustomTarget =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
