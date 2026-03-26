// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_metrics_dao.dart';

// ignore_for_file: type=lint
mixin _$MonthlyMetricsDaoMixin on DatabaseAccessor<AppDatabase> {
  $FamiliesTable get families => attachedDatabase.families;
  $MonthlyMetricsTable get monthlyMetrics => attachedDatabase.monthlyMetrics;
  MonthlyMetricsDaoManager get managers => MonthlyMetricsDaoManager(this);
}

class MonthlyMetricsDaoManager {
  final _$MonthlyMetricsDaoMixin _db;
  MonthlyMetricsDaoManager(this._db);
  $$FamiliesTableTableManager get families =>
      $$FamiliesTableTableManager(_db.attachedDatabase, _db.families);
  $$MonthlyMetricsTableTableManager get monthlyMetrics =>
      $$MonthlyMetricsTableTableManager(
        _db.attachedDatabase,
        _db.monthlyMetrics,
      );
}
