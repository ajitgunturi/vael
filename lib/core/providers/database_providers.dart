import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../database/daos/account_dao.dart';

/// Root provider for the app's drift database.
///
/// Override this in tests with an in-memory database.
/// In production, supply a file-backed NativeDatabase.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(NativeDatabase.memory());
  ref.onDispose(() => db.close());
  return db;
});

/// Derives an [AccountDao] from the database.
final accountDaoProvider = Provider<AccountDao>((ref) {
  return AccountDao(ref.watch(databaseProvider));
});
