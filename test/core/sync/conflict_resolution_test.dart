import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/sync/changeset_serializer.dart';
import 'package:vael/core/sync/conflict_resolver.dart';

void main() {
  group('ConflictResolver', () {
    late ConflictResolver resolver;

    setUp(() {
      resolver = ConflictResolver();
    });

    group('Last-Writer-Wins (same entity updated)', () {
      test('later timestamp wins', () {
        final local = SyncOperation(
          op: OpType.update,
          table: 'accounts',
          id: 'acc-001',
          data: {'balance': 500000},
        );
        final remote = SyncOperation(
          op: OpType.update,
          table: 'accounts',
          id: 'acc-001',
          data: {'balance': 485000},
        );

        final result = resolver.resolve(
          local: local,
          remote: remote,
          localTimestamp: DateTime.utc(2026, 3, 20, 10, 0),
          remoteTimestamp: DateTime.utc(2026, 3, 20, 10, 5), // Later
        );

        expect(result, ConflictResolution.acceptRemote);
      });

      test('local wins when local timestamp is later', () {
        final local = SyncOperation(
          op: OpType.update,
          table: 'accounts',
          id: 'acc-001',
          data: {'balance': 500000},
        );
        final remote = SyncOperation(
          op: OpType.update,
          table: 'accounts',
          id: 'acc-001',
          data: {'balance': 485000},
        );

        final result = resolver.resolve(
          local: local,
          remote: remote,
          localTimestamp: DateTime.utc(2026, 3, 20, 10, 10), // Later
          remoteTimestamp: DateTime.utc(2026, 3, 20, 10, 5),
        );

        expect(result, ConflictResolution.keepLocal);
      });

      test('equal timestamps use device ID as tiebreaker', () {
        final local = SyncOperation(
          op: OpType.update,
          table: 'goals',
          id: 'goal-001',
          data: {'target': 1000000},
        );
        final remote = SyncOperation(
          op: OpType.update,
          table: 'goals',
          id: 'goal-001',
          data: {'target': 2000000},
        );

        final sameTime = DateTime.utc(2026, 3, 20, 10, 0);

        // Deterministic: higher device ID wins
        final result = resolver.resolve(
          local: local,
          remote: remote,
          localTimestamp: sameTime,
          remoteTimestamp: sameTime,
          localDeviceId: 'device-A',
          remoteDeviceId: 'device-B',
        );

        // 'device-B' > 'device-A' lexicographically
        expect(result, ConflictResolution.acceptRemote);
      });
    });

    group('Additive Merge (new transactions)', () {
      test('both inserts on different entities are kept', () {
        final local = SyncOperation(
          op: OpType.insert,
          table: 'transactions',
          id: 'txn-local',
          data: {'amount': 15000},
        );
        final remote = SyncOperation(
          op: OpType.insert,
          table: 'transactions',
          id: 'txn-remote',
          data: {'amount': 20000},
        );

        final result = resolver.resolveInserts(local: local, remote: remote);

        expect(result, ConflictResolution.mergeBoth);
      });
    });

    group('Delete Wins', () {
      test('delete wins over update', () {
        final localDelete = SyncOperation(
          op: OpType.delete,
          table: 'transactions',
          id: 'txn-001',
          deletedAt: DateTime.utc(2026, 3, 20, 10, 0),
        );
        final remoteUpdate = SyncOperation(
          op: OpType.update,
          table: 'transactions',
          id: 'txn-001',
          data: {'amount': 25000},
        );

        final result = resolver.resolveDeleteVsUpdate(
          delete: localDelete,
          update: remoteUpdate,
        );

        expect(result, ConflictResolution.acceptDelete);
      });

      test('remote delete wins over local update', () {
        final localUpdate = SyncOperation(
          op: OpType.update,
          table: 'transactions',
          id: 'txn-001',
          data: {'amount': 25000},
        );
        final remoteDelete = SyncOperation(
          op: OpType.delete,
          table: 'transactions',
          id: 'txn-001',
          deletedAt: DateTime.utc(2026, 3, 20, 10, 0),
        );

        final result = resolver.resolveDeleteVsUpdate(
          delete: remoteDelete,
          update: localUpdate,
        );

        expect(result, ConflictResolution.acceptDelete);
      });
    });

    group('Schema Version Mismatch', () {
      test('blocks sync when remote schema is newer', () {
        final result = resolver.checkSchemaCompatibility(
          localVersion: 4,
          remoteVersion: 5,
        );

        expect(result, SchemaCheck.blocked);
      });

      test('allows sync when schemas match', () {
        final result = resolver.checkSchemaCompatibility(
          localVersion: 5,
          remoteVersion: 5,
        );

        expect(result, SchemaCheck.compatible);
      });

      test(
        'allows sync when local schema is newer (can handle older data)',
        () {
          final result = resolver.checkSchemaCompatibility(
            localVersion: 5,
            remoteVersion: 4,
          );

          expect(result, SchemaCheck.compatible);
        },
      );
    });

    group('Deterministic Mock Clocks', () {
      test('conflict resolution is deterministic with fixed timestamps', () {
        final local = SyncOperation(
          op: OpType.update,
          table: 'budgets',
          id: 'budget-001',
          data: {'limit': 50000},
        );
        final remote = SyncOperation(
          op: OpType.update,
          table: 'budgets',
          id: 'budget-001',
          data: {'limit': 60000},
        );

        // Run 100 times — must always produce same result
        final results = List.generate(
          100,
          (_) => resolver.resolve(
            local: local,
            remote: remote,
            localTimestamp: DateTime.utc(2026, 3, 20, 10, 0),
            remoteTimestamp: DateTime.utc(2026, 3, 20, 10, 5),
          ),
        );

        expect(results.toSet(), hasLength(1)); // All identical
        expect(results.first, ConflictResolution.acceptRemote);
      });
    });
  });
}
