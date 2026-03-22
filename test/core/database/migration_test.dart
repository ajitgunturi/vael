import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';

void main() {
  group('Schema migration', () {
    test('schema version is 10', () {
      final db = AppDatabase(NativeDatabase.memory());
      expect(db.schemaVersion, 10);
      db.close();
    });

    test('transactions table has deletedAt column', () async {
      final db = AppDatabase(NativeDatabase.memory());

      // Insert prerequisite rows
      await db
          .into(db.families)
          .insert(
            FamiliesCompanion.insert(
              id: 'fam-1',
              name: 'Test',
              createdAt: DateTime(2025),
            ),
          );
      await db
          .into(db.users)
          .insert(
            UsersCompanion.insert(
              id: 'user-1',
              email: 'a@b.com',
              displayName: 'A',
              role: 'admin',
              familyId: 'fam-1',
            ),
          );
      await db
          .into(db.accounts)
          .insert(
            AccountsCompanion.insert(
              id: 'acc-1',
              name: 'Savings',
              type: 'savings',
              balance: 0,
              visibility: 'shared',
              familyId: 'fam-1',
              userId: 'user-1',
            ),
          );

      // Insert a transaction — deletedAt should default to null
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: 'txn-1',
              amount: 100,
              date: DateTime(2025, 1, 1),
              kind: 'expense',
              accountId: 'acc-1',
              familyId: 'fam-1',
            ),
          );

      final rows = await db.select(db.transactions).get();
      expect(rows, hasLength(1));
      expect(rows.first.deletedAt, isNull);

      await db.close();
    });

    test('recurring_rules table has deletedAt column', () async {
      final db = AppDatabase(NativeDatabase.memory());

      await db
          .into(db.families)
          .insert(
            FamiliesCompanion.insert(
              id: 'fam-1',
              name: 'Test',
              createdAt: DateTime(2025),
            ),
          );
      await db
          .into(db.users)
          .insert(
            UsersCompanion.insert(
              id: 'user-1',
              email: 'a@b.com',
              displayName: 'A',
              role: 'admin',
              familyId: 'fam-1',
            ),
          );
      await db
          .into(db.accounts)
          .insert(
            AccountsCompanion.insert(
              id: 'acc-1',
              name: 'Savings',
              type: 'savings',
              balance: 0,
              visibility: 'shared',
              familyId: 'fam-1',
              userId: 'user-1',
            ),
          );

      await db
          .into(db.recurringRules)
          .insert(
            RecurringRulesCompanion.insert(
              id: 'rule-1',
              name: 'Monthly SIP',
              amount: 500000,
              kind: 'expense',
              frequencyMonths: 1.0,
              startDate: DateTime(2025, 1, 1),
              accountId: 'acc-1',
              familyId: 'fam-1',
              userId: 'user-1',
              createdAt: DateTime(2025, 1, 1),
            ),
          );

      final rows = await db.select(db.recurringRules).get();
      expect(rows, hasLength(1));
      expect(rows.first.deletedAt, isNull);

      await db.close();
    });
  });
}
