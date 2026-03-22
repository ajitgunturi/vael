import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../database/database_path.dart';
import '../database/daos/account_dao.dart';
import '../database/daos/budget_dao.dart';

/// Root provider for the app's drift database.
///
/// In production uses a file-backed database with an opaque filename
/// (SHA-256 hash — no financial semantics leaked in the path).
/// Override this in tests with `NativeDatabase.memory()`.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(
    LazyDatabase(() async {
      final file = await databaseFile();
      return NativeDatabase(file);
    }),
  );
  ref.onDispose(() => db.close());
  return db;
});

/// Derives an [AccountDao] from the database.
final accountDaoProvider = Provider<AccountDao>((ref) {
  return AccountDao(ref.watch(databaseProvider));
});

/// Derives a [BudgetDao] from the database.
final budgetDaoProvider = Provider<BudgetDao>((ref) {
  return BudgetDao(ref.watch(databaseProvider));
});
