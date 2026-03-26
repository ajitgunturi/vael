import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../database/database.dart';
import '../database/database_path.dart';
import '../database/daos/account_dao.dart';
import '../database/daos/audit_log_dao.dart';
import '../database/daos/balance_snapshot_dao.dart';
import '../database/daos/budget_dao.dart';
import '../database/daos/savings_allocation_rule_dao.dart';
import '../database/daos/sync_changelog_dao.dart';

const _dbKeyStorageKey = 'vael_db_encryption_key';

/// Generates a random 32-byte hex key for SQLCipher.
String _generateDbKey() {
  final random = Random.secure();
  final bytes = List<int>.generate(32, (_) => random.nextInt(256));
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

/// Retrieves or creates the SQLCipher encryption key from secure storage.
Future<String> _getOrCreateDbKey() async {
  const storage = FlutterSecureStorage();
  var key = await storage.read(key: _dbKeyStorageKey);
  if (key == null) {
    key = _generateDbKey();
    await storage.write(key: _dbKeyStorageKey, value: key);
  }
  return key;
}

/// Root provider for the app's drift database.
///
/// In production, uses SQLCipher-encrypted file-backed database.
/// In debug mode, uses unencrypted NativeDatabase for fast iteration.
/// Override this in tests with `NativeDatabase.memory()`.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(
    LazyDatabase(() async {
      final file = await databaseFile();

      if (kDebugMode) {
        // Unencrypted for dev speed
        return NativeDatabase(file);
      }

      // Production: SQLCipher encryption via PRAGMA key
      final dbKey = await _getOrCreateDbKey();
      return NativeDatabase(
        file,
        setup: (rawDb) {
          rawDb.execute("PRAGMA key = '${_escapeKey(dbKey)}'");
          rawDb.execute('PRAGMA cipher_page_size = 4096');
        },
      );
    }),
  );
  ref.onDispose(() => db.close());
  return db;
});

/// Escapes single quotes in the key for PRAGMA statement.
String _escapeKey(String key) => key.replaceAll("'", "''");

/// Derives an [AccountDao] from the database.
final accountDaoProvider = Provider<AccountDao>((ref) {
  return AccountDao(ref.watch(databaseProvider));
});

/// Derives a [BudgetDao] from the database.
final budgetDaoProvider = Provider<BudgetDao>((ref) {
  return BudgetDao(ref.watch(databaseProvider));
});

/// Derives an [AuditLogDao] from the database.
final auditLogDaoProvider = Provider<AuditLogDao>((ref) {
  return AuditLogDao(ref.watch(databaseProvider));
});

/// Derives a [BalanceSnapshotDao] from the database.
final balanceSnapshotDaoProvider = Provider<BalanceSnapshotDao>((ref) {
  return BalanceSnapshotDao(ref.watch(databaseProvider));
});

/// Derives a [SyncChangelogDao] from the database.
final syncChangelogDaoProvider = Provider<SyncChangelogDao>((ref) {
  return SyncChangelogDao(ref.watch(databaseProvider));
});

/// Derives a [SavingsAllocationRuleDao] from the database.
final savingsAllocationRuleDaoProvider = Provider<SavingsAllocationRuleDao>((
  ref,
) {
  return SavingsAllocationRuleDao(ref.watch(databaseProvider));
});
