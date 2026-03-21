import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Families table', () {
    test('should insert and query a family', () async {
      await db
          .into(db.families)
          .insert(
            FamiliesCompanion.insert(
              id: 'fam-1',
              name: 'Gupta Family',
              createdAt: DateTime(2024, 1, 1),
            ),
          );

      final rows = await db.select(db.families).get();
      expect(rows, hasLength(1));
      expect(rows.first.name, 'Gupta Family');
      expect(rows.first.baseCurrency, 'INR');
    });
  });

  group('Users table', () {
    test('should insert a user with FK to family', () async {
      await db
          .into(db.families)
          .insert(
            FamiliesCompanion.insert(
              id: 'fam-1',
              name: 'Test Family',
              createdAt: DateTime(2024, 1, 1),
            ),
          );

      await db
          .into(db.users)
          .insert(
            UsersCompanion.insert(
              id: 'user-1',
              email: 'ajit@example.com',
              displayName: 'Ajit',
              role: 'admin',
              familyId: 'fam-1',
            ),
          );

      final rows = await db.select(db.users).get();
      expect(rows, hasLength(1));
      expect(rows.first.displayName, 'Ajit');
      expect(rows.first.role, 'admin');
      expect(rows.first.familyId, 'fam-1');
      expect(rows.first.avatarUrl, isNull);
    });
  });

  group('Accounts table', () {
    Future<void> seedFamilyAndUser() async {
      await db
          .into(db.families)
          .insert(
            FamiliesCompanion.insert(
              id: 'fam-1',
              name: 'Test Family',
              createdAt: DateTime(2024, 1, 1),
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
    }

    test('should insert an account with FK to family and user', () async {
      await seedFamilyAndUser();

      await db
          .into(db.accounts)
          .insert(
            AccountsCompanion.insert(
              id: 'acc-1',
              name: 'HDFC Savings',
              type: 'savings',
              balance: 1500000, // ₹15,000.00 in paise
              visibility: 'shared',
              familyId: 'fam-1',
              userId: 'user-1',
            ),
          );

      final rows = await db.select(db.accounts).get();
      expect(rows, hasLength(1));
      expect(rows.first.balance, 1500000);
      expect(rows.first.currency, 'INR');
      expect(rows.first.sharedWithFamily, true);
      expect(rows.first.deletedAt, isNull);
    });

    test('should support soft delete via deletedAt', () async {
      await seedFamilyAndUser();
      final now = DateTime.now();

      await db
          .into(db.accounts)
          .insert(
            AccountsCompanion.insert(
              id: 'acc-1',
              name: 'Old Account',
              type: 'savings',
              balance: 0,
              visibility: 'shared',
              familyId: 'fam-1',
              userId: 'user-1',
            ),
          );

      // Soft-delete the account
      await (db.update(db.accounts)..where((t) => t.id.equals('acc-1'))).write(
        AccountsCompanion(deletedAt: Value(now)),
      );

      // Query all — still present
      final all = await db.select(db.accounts).get();
      expect(all, hasLength(1));
      expect(all.first.deletedAt, isNotNull);

      // Filter out soft-deleted
      final active = await (db.select(
        db.accounts,
      )..where((t) => t.deletedAt.isNull())).get();
      expect(active, isEmpty);
    });
  });

  group('Categories table', () {
    test('should insert a category', () async {
      await db
          .into(db.families)
          .insert(
            FamiliesCompanion.insert(
              id: 'fam-1',
              name: 'Test Family',
              createdAt: DateTime(2024, 1, 1),
            ),
          );

      await db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              id: 'cat-1',
              name: 'Groceries',
              groupName: 'essential',
              type: 'EXPENSE',
              familyId: 'fam-1',
            ),
          );

      final rows = await db.select(db.categories).get();
      expect(rows, hasLength(1));
      expect(rows.first.name, 'Groceries');
      expect(rows.first.groupName, 'essential');
      expect(rows.first.type, 'EXPENSE');
    });
  });

  group('Transactions table', () {
    test('should insert a transaction with integer amount (paise)', () async {
      await db
          .into(db.families)
          .insert(
            FamiliesCompanion.insert(
              id: 'fam-1',
              name: 'Test Family',
              createdAt: DateTime(2024, 1, 1),
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
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: 'txn-1',
              amount: 4999, // ₹49.99
              date: DateTime(2024, 3, 15),
              kind: 'expense',
              accountId: 'acc-1',
              familyId: 'fam-1',
            ),
          );

      final rows = await db.select(db.transactions).get();
      expect(rows, hasLength(1));
      expect(rows.first.amount, 4999);
      expect(rows.first.kind, 'expense');
      expect(rows.first.description, isNull);
      expect(rows.first.categoryId, isNull);
      expect(rows.first.toAccountId, isNull);
    });
  });

  group('BalanceSnapshots table', () {
    test('should insert a balance snapshot', () async {
      await db
          .into(db.families)
          .insert(
            FamiliesCompanion.insert(
              id: 'fam-1',
              name: 'Test Family',
              createdAt: DateTime(2024, 1, 1),
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
          .into(db.balanceSnapshots)
          .insert(
            BalanceSnapshotsCompanion.insert(
              id: 'snap-1',
              accountId: 'acc-1',
              snapshotDate: DateTime(2024, 3, 31),
              balance: 2500000, // ₹25,000.00
              familyId: 'fam-1',
            ),
          );

      final rows = await db.select(db.balanceSnapshots).get();
      expect(rows, hasLength(1));
      expect(rows.first.balance, 2500000);
    });
  });

  group('AuditLog table', () {
    test('should insert an audit log entry', () async {
      await db
          .into(db.families)
          .insert(
            FamiliesCompanion.insert(
              id: 'fam-1',
              name: 'Test Family',
              createdAt: DateTime(2024, 1, 1),
            ),
          );

      await db
          .into(db.auditLog)
          .insert(
            AuditLogCompanion.insert(
              id: 'log-1',
              entityType: 'account',
              entityId: 'acc-1',
              action: 'create',
              actorUserId: 'user-1',
              createdAt: DateTime(2024, 3, 15, 10, 30),
              familyId: 'fam-1',
            ),
          );

      final rows = await db.select(db.auditLog).get();
      expect(rows, hasLength(1));
      expect(rows.first.entityType, 'account');
      expect(rows.first.action, 'create');
      expect(rows.first.diff, isNull);
    });
  });

  group('Family isolation', () {
    test('should scope queries by familyId', () async {
      // Insert two families
      await db
          .into(db.families)
          .insert(
            FamiliesCompanion.insert(
              id: 'fam-1',
              name: 'Family A',
              createdAt: DateTime(2024, 1, 1),
            ),
          );
      await db
          .into(db.families)
          .insert(
            FamiliesCompanion.insert(
              id: 'fam-2',
              name: 'Family B',
              createdAt: DateTime(2024, 1, 1),
            ),
          );

      // Insert categories in each family
      await db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              id: 'cat-1',
              name: 'Groceries',
              groupName: 'essential',
              type: 'EXPENSE',
              familyId: 'fam-1',
            ),
          );
      await db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              id: 'cat-2',
              name: 'Rent',
              groupName: 'essential',
              type: 'EXPENSE',
              familyId: 'fam-1',
            ),
          );
      await db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              id: 'cat-3',
              name: 'Dining',
              groupName: 'nonEssential',
              type: 'EXPENSE',
              familyId: 'fam-2',
            ),
          );

      // Query scoped to fam-1
      final fam1Cats = await (db.select(
        db.categories,
      )..where((t) => t.familyId.equals('fam-1'))).get();
      expect(fam1Cats, hasLength(2));

      // Query scoped to fam-2
      final fam2Cats = await (db.select(
        db.categories,
      )..where((t) => t.familyId.equals('fam-2'))).get();
      expect(fam2Cats, hasLength(1));
      expect(fam2Cats.first.name, 'Dining');
    });
  });
}
