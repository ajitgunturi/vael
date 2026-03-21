import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/sync/changeset_serializer.dart';

void main() {
  group('ChangesetSerializer', () {
    late ChangesetSerializer serializer;

    setUp(() {
      serializer = ChangesetSerializer();
    });

    test('round-trip serialize/deserialize preserves changeset', () {
      final changeset = Changeset(
        deviceId: 'device-A',
        sequence: 42,
        timestamp: DateTime.utc(2026, 3, 20, 10, 30),
        operations: [
          SyncOperation(
            op: OpType.insert,
            table: 'transactions',
            id: 'txn-001',
            data: {'amount': 15000, 'description': 'Groceries'},
          ),
        ],
      );

      final json = serializer.serialize(changeset);
      final restored = serializer.deserialize(json);

      expect(restored.deviceId, 'device-A');
      expect(restored.sequence, 42);
      expect(restored.timestamp, DateTime.utc(2026, 3, 20, 10, 30));
      expect(restored.operations, hasLength(1));
      expect(restored.operations.first.op, OpType.insert);
      expect(restored.operations.first.table, 'transactions');
      expect(restored.operations.first.id, 'txn-001');
      expect(restored.operations.first.data!['amount'], 15000);
    });

    test('serializes INSERT operation', () {
      final changeset = Changeset(
        deviceId: 'dev-1',
        sequence: 1,
        timestamp: DateTime.utc(2026, 3, 20),
        operations: [
          SyncOperation(
            op: OpType.insert,
            table: 'accounts',
            id: 'acc-001',
            data: {'name': 'Savings', 'balance': 500000},
          ),
        ],
      );

      final json = serializer.serialize(changeset);
      final decoded = jsonDecode(json) as Map<String, dynamic>;

      final ops = decoded['operations'] as List;
      expect(ops.first['op'], 'INSERT');
      expect(ops.first['data']['name'], 'Savings');
      expect(ops.first['prev'], isNull);
    });

    test('serializes UPDATE operation with prev values', () {
      final changeset = Changeset(
        deviceId: 'dev-1',
        sequence: 2,
        timestamp: DateTime.utc(2026, 3, 20),
        operations: [
          SyncOperation(
            op: OpType.update,
            table: 'accounts',
            id: 'acc-001',
            data: {'balance': 485000},
            prev: {'balance': 500000},
          ),
        ],
      );

      final json = serializer.serialize(changeset);
      final decoded = jsonDecode(json) as Map<String, dynamic>;

      final op = (decoded['operations'] as List).first;
      expect(op['op'], 'UPDATE');
      expect(op['data']['balance'], 485000);
      expect(op['prev']['balance'], 500000);
    });

    test('serializes DELETE operation with deleted_at', () {
      final changeset = Changeset(
        deviceId: 'dev-1',
        sequence: 3,
        timestamp: DateTime.utc(2026, 3, 20, 10, 30),
        operations: [
          SyncOperation(
            op: OpType.delete,
            table: 'transactions',
            id: 'txn-001',
            deletedAt: DateTime.utc(2026, 3, 20, 10, 30),
          ),
        ],
      );

      final json = serializer.serialize(changeset);
      final decoded = jsonDecode(json) as Map<String, dynamic>;

      final op = (decoded['operations'] as List).first;
      expect(op['op'], 'DELETE');
      expect(op['deleted_at'], '2026-03-20T10:30:00.000Z');
    });

    test('handles multiple operations in one changeset', () {
      final changeset = Changeset(
        deviceId: 'dev-1',
        sequence: 5,
        timestamp: DateTime.utc(2026, 3, 20),
        operations: [
          SyncOperation(
            op: OpType.insert,
            table: 'transactions',
            id: 'txn-001',
            data: {'amount': 15000},
          ),
          SyncOperation(
            op: OpType.update,
            table: 'accounts',
            id: 'acc-001',
            data: {'balance': 485000},
            prev: {'balance': 500000},
          ),
          SyncOperation(
            op: OpType.delete,
            table: 'transactions',
            id: 'txn-002',
            deletedAt: DateTime.utc(2026, 3, 20),
          ),
        ],
      );

      final json = serializer.serialize(changeset);
      final restored = serializer.deserialize(json);

      expect(restored.operations, hasLength(3));
      expect(restored.operations[0].op, OpType.insert);
      expect(restored.operations[1].op, OpType.update);
      expect(restored.operations[2].op, OpType.delete);
    });

    test('serialize produces valid JSON', () {
      final changeset = Changeset(
        deviceId: 'dev-1',
        sequence: 1,
        timestamp: DateTime.utc(2026, 3, 20),
        operations: [],
      );

      final json = serializer.serialize(changeset);
      expect(() => jsonDecode(json), returnsNormally);
    });

    test('serializes timestamp as ISO 8601 UTC', () {
      final changeset = Changeset(
        deviceId: 'dev-1',
        sequence: 1,
        timestamp: DateTime.utc(2026, 3, 20, 10, 30, 45),
        operations: [],
      );

      final json = serializer.serialize(changeset);
      final decoded = jsonDecode(json) as Map<String, dynamic>;

      expect(decoded['timestamp'], '2026-03-20T10:30:45.000Z');
    });

    test('toBytes/fromBytes produce UTF-8 encoded bytes', () {
      final changeset = Changeset(
        deviceId: 'dev-1',
        sequence: 1,
        timestamp: DateTime.utc(2026, 3, 20),
        operations: [
          SyncOperation(
            op: OpType.insert,
            table: 'transactions',
            id: 'txn-001',
            data: {'description': 'किराना'},
          ),
        ],
      );

      final bytes = serializer.toBytes(changeset);
      final restored = serializer.fromBytes(bytes);

      expect(restored.operations.first.data!['description'], 'किराना');
    });
  });
}
