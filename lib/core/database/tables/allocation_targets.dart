import 'package:drift/drift.dart';

import 'life_profiles.dart';

/// Custom glide-path overrides per age band for a life profile.
class AllocationTargets extends Table {
  TextColumn get id => text()();
  TextColumn get lifeProfileId => text().references(LifeProfiles, #id)();
  IntColumn get ageBandStart => integer()(); // e.g. 20, 30, 40...
  IntColumn get ageBandEnd => integer()(); // e.g. 30, 40, 50...
  IntColumn get equityBp => integer()(); // basis points (7000 = 70%)
  IntColumn get debtBp => integer()();
  IntColumn get goldBp => integer()();
  IntColumn get cashBp => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
