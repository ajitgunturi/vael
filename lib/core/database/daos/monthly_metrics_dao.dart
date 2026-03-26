import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/monthly_metrics.dart';

part 'monthly_metrics_dao.g.dart';

@DriftAccessor(tables: [MonthlyMetrics])
class MonthlyMetricsDao extends DatabaseAccessor<AppDatabase>
    with _$MonthlyMetricsDaoMixin {
  MonthlyMetricsDao(super.db);

  /// Returns the most recent [months] metrics for [familyId], ordered by month DESC.
  Future<List<MonthlyMetric>> getRecent(String familyId, int months) {
    return (select(monthlyMetrics)
          ..where((m) => m.familyId.equals(familyId))
          ..orderBy([(m) => OrderingTerm.desc(m.month)])
          ..limit(months))
        .get();
  }

  /// Returns a single metric row for a specific [familyId] and [month] (YYYY-MM).
  Future<MonthlyMetric?> getByMonth(String familyId, String month) {
    return (select(monthlyMetrics)
          ..where((m) => m.familyId.equals(familyId) & m.month.equals(month)))
        .getSingleOrNull();
  }

  /// Inserts or updates a monthly metric entry (upsert by primary key).
  Future<void> upsert(MonthlyMetricsCompanion entry) {
    return into(monthlyMetrics).insertOnConflictUpdate(entry);
  }

  /// Updates only the yearsToFi column for an existing row.
  ///
  /// No-ops if the row does not exist.
  Future<void> updateYearsToFi(String id, int? yearsToFi) {
    return (update(monthlyMetrics)..where((m) => m.id.equals(id))).write(
      MonthlyMetricsCompanion(yearsToFi: Value(yearsToFi)),
    );
  }

  /// Watches the most recent [months] metrics for [familyId], ordered by month DESC.
  Stream<List<MonthlyMetric>> watchRecent(String familyId, int months) {
    return (select(monthlyMetrics)
          ..where((m) => m.familyId.equals(familyId))
          ..orderBy([(m) => OrderingTerm.desc(m.month)])
          ..limit(months))
        .watch();
  }
}
