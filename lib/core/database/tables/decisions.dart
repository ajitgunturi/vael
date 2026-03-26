import 'package:drift/drift.dart';

import 'families.dart';

/// A financial decision record tracking what-if scenarios and their outcomes.
class Decisions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get familyId => text().references(Families, #id)();
  TextColumn get decisionType => text()(); // DecisionType as string
  TextColumn get name => text()(); // user-given or auto-generated name
  TextColumn get parameters => text()(); // JSON blob of decision parameters
  TextColumn get status => text().withDefault(
    const Constant('preview'),
  )(); // 'preview' | 'implemented'
  IntColumn get fiDelayYears => integer().nullable()(); // cached impact result
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get implementedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
