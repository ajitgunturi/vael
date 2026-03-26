import 'package:drift/drift.dart';

import 'families.dart';
import 'users.dart';

/// A financial account (bank, wallet, credit card, etc.).
class Accounts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // AccountType as string
  TextColumn get institution => text().nullable()();
  IntColumn get balance => integer()(); // paise (minor units)
  TextColumn get currency => text().withDefault(const Constant('INR'))();
  TextColumn get visibility => text()(); // Visibility as string
  BoolColumn get sharedWithFamily =>
      boolean().withDefault(const Constant(true))();
  TextColumn get familyId => text().references(Families, #id)();
  TextColumn get userId => text().references(Users, #id)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get liquidityTier => text().nullable()(); // LiquidityTier.name
  BoolColumn get isEmergencyFund =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isOpportunityFund =>
      boolean().withDefault(const Constant(false))();
  IntColumn get opportunityFundTargetPaise => integer().nullable()();
  IntColumn get minimumBalancePaise =>
      integer().nullable()(); // threshold for cash flow alerts

  @override
  Set<Column> get primaryKey => {id};
}
