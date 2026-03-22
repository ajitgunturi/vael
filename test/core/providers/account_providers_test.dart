import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/database/daos/account_dao.dart';
import 'package:vael/core/providers/database_providers.dart';
import 'package:vael/core/providers/account_providers.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> _seedFamily(String familyId) async {
    await db
        .into(db.families)
        .insert(
          FamiliesCompanion.insert(
            id: familyId,
            name: 'Family $familyId',
            createdAt: DateTime(2025),
          ),
        );
    await db
        .into(db.users)
        .insert(
          UsersCompanion.insert(
            id: 'user_$familyId',
            email: '$familyId@test.com',
            displayName: 'User $familyId',
            role: 'admin',
            familyId: familyId,
          ),
        );
  }

  Future<void> _insertAccount({
    required String id,
    required String familyId,
    String type = 'savings',
    int balance = 0,
    String visibility = 'shared',
    DateTime? deletedAt,
  }) async {
    await db
        .into(db.accounts)
        .insert(
          AccountsCompanion(
            id: Value(id),
            name: Value('Account $id'),
            type: Value(type),
            balance: Value(balance),
            visibility: Value(visibility),
            familyId: Value(familyId),
            userId: Value('user_$familyId'),
            deletedAt: Value(deletedAt),
          ),
        );
  }

  group('databaseProvider', () {
    test('provides the overridden database instance', () {
      final result = container.read(databaseProvider);
      expect(result, same(db));
    });
  });

  group('accountDaoProvider', () {
    test('derives AccountDao from the database', () {
      final dao = container.read(accountDaoProvider);
      expect(dao, isA<AccountDao>());
    });
  });

  group('accountsProvider', () {
    test('streams accounts for a given family', () async {
      await _seedFamily('fam_a');
      await _insertAccount(id: 'acc_1', familyId: 'fam_a');
      await _insertAccount(id: 'acc_2', familyId: 'fam_a');

      // Read the stream provider
      final sub = container.listen(accountsProvider('fam_a'), (_, __) {});

      // Allow the stream to emit
      await Future<void>.delayed(Duration.zero);

      final state = sub.read();
      expect(state.value, isNotNull);
      expect(state.value, hasLength(2));
    });

    test('excludes soft-deleted accounts', () async {
      await _seedFamily('fam_a');
      await _insertAccount(id: 'acc_1', familyId: 'fam_a');
      await _insertAccount(
        id: 'acc_2',
        familyId: 'fam_a',
        deletedAt: DateTime(2025, 6, 1),
      );

      final sub = container.listen(accountsProvider('fam_a'), (_, __) {});

      await Future<void>.delayed(Duration.zero);

      final state = sub.read();
      expect(state.value, hasLength(1));
      expect(state.value!.first.id, 'acc_1');
    });

    test('rebuilds when an account is inserted', () async {
      await _seedFamily('fam_a');
      await _insertAccount(id: 'acc_1', familyId: 'fam_a');

      final emissions = <List<Account>>[];
      container.listen(accountsProvider('fam_a'), (_, next) {
        if (next.hasValue) emissions.add(next.value!);
      });

      // Wait for first emission
      await Future<void>.delayed(Duration.zero);

      // Insert a new account — stream should re-emit
      await _insertAccount(id: 'acc_2', familyId: 'fam_a');

      // Give drift's stream time to propagate
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(emissions.length, greaterThanOrEqualTo(2));
      expect(emissions.last, hasLength(2));
    });

    test('isolates accounts by family', () async {
      await _seedFamily('fam_a');
      await _seedFamily('fam_b');
      await _insertAccount(id: 'acc_1', familyId: 'fam_a');
      await _insertAccount(id: 'acc_2', familyId: 'fam_b');

      final sub = container.listen(accountsProvider('fam_a'), (_, __) {});

      await Future<void>.delayed(Duration.zero);

      final state = sub.read();
      expect(state.value, hasLength(1));
      expect(state.value!.first.id, 'acc_1');
    });
  });

  group('netWorthProvider', () {
    test(
      'computes assets minus liabilities for shared/nameOnly accounts',
      () async {
        await _seedFamily('fam_a');

        // Assets
        await _insertAccount(
          id: 'savings_1',
          familyId: 'fam_a',
          type: 'savings',
          balance: 500000, // ₹5,000
          visibility: 'shared',
        );
        await _insertAccount(
          id: 'invest_1',
          familyId: 'fam_a',
          type: 'investment',
          balance: 1000000, // ₹10,000
          visibility: 'nameOnly',
        );

        // Liabilities
        await _insertAccount(
          id: 'cc_1',
          familyId: 'fam_a',
          type: 'creditCard',
          balance: 200000, // ₹2,000
          visibility: 'shared',
        );
        await _insertAccount(
          id: 'loan_1',
          familyId: 'fam_a',
          type: 'loan',
          balance: 300000, // ₹3,000
          visibility: 'shared',
        );

        final sub = container.listen(netWorthProvider('fam_a'), (_, __) {});

        await Future<void>.delayed(Duration.zero);

        final state = sub.read();
        // Net worth = (500000 + 1000000) - (200000 + 300000) = 1000000
        expect(state.value, 1000000);
      },
    );

    test('excludes private accounts from family net worth', () async {
      await _seedFamily('fam_a');

      await _insertAccount(
        id: 'savings_1',
        familyId: 'fam_a',
        type: 'savings',
        balance: 500000,
        visibility: 'shared',
      );
      await _insertAccount(
        id: 'savings_private',
        familyId: 'fam_a',
        type: 'savings',
        balance: 300000,
        visibility: 'hidden',
      );

      final sub = container.listen(netWorthProvider('fam_a'), (_, __) {});

      await Future<void>.delayed(Duration.zero);

      final state = sub.read();
      // Only the shared account counts
      expect(state.value, 500000);
    });

    test('returns zero when no accounts exist', () async {
      await _seedFamily('fam_a');

      final sub = container.listen(netWorthProvider('fam_a'), (_, __) {});

      await Future<void>.delayed(Duration.zero);

      final state = sub.read();
      expect(state.value, 0);
    });

    test('excludes soft-deleted accounts', () async {
      await _seedFamily('fam_a');

      await _insertAccount(
        id: 'savings_1',
        familyId: 'fam_a',
        type: 'savings',
        balance: 500000,
        visibility: 'shared',
      );
      await _insertAccount(
        id: 'savings_del',
        familyId: 'fam_a',
        type: 'savings',
        balance: 999999,
        visibility: 'shared',
        deletedAt: DateTime(2025, 6, 1),
      );

      final sub = container.listen(netWorthProvider('fam_a'), (_, __) {});

      await Future<void>.delayed(Duration.zero);

      final state = sub.read();
      expect(state.value, 500000);
    });

    test('treats wallet as asset and creditCard as liability', () async {
      await _seedFamily('fam_a');

      await _insertAccount(
        id: 'wallet_1',
        familyId: 'fam_a',
        type: 'wallet',
        balance: 100000,
        visibility: 'shared',
      );
      await _insertAccount(
        id: 'cc_1',
        familyId: 'fam_a',
        type: 'creditCard',
        balance: 50000,
        visibility: 'shared',
      );

      final sub = container.listen(netWorthProvider('fam_a'), (_, __) {});

      await Future<void>.delayed(Duration.zero);

      final state = sub.read();
      // wallet (asset) - creditCard (liability) = 50000
      expect(state.value, 50000);
    });
  });
}
