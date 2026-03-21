import 'dart:convert';
import 'dart:typed_data';

/// Serializes/deserializes sync changesets to/from JSON.
///
/// Changeset format matches the SYNC.md specification:
/// ```json
/// {
///   "device_id": "abc123",
///   "sequence": 42,
///   "timestamp": "2026-03-20T10:30:00Z",
///   "operations": [...]
/// }
/// ```
class ChangesetSerializer {
  String serialize(Changeset changeset) {
    return jsonEncode(changeset.toJson());
  }

  Changeset deserialize(String json) {
    return Changeset.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  Uint8List toBytes(Changeset changeset) {
    return Uint8List.fromList(utf8.encode(serialize(changeset)));
  }

  Changeset fromBytes(Uint8List bytes) {
    return deserialize(utf8.decode(bytes));
  }
}

/// A batch of sync operations from a single device.
class Changeset {
  final String deviceId;
  final int sequence;
  final DateTime timestamp;
  final List<SyncOperation> operations;

  Changeset({
    required this.deviceId,
    required this.sequence,
    required this.timestamp,
    required this.operations,
  });

  Map<String, dynamic> toJson() => {
        'device_id': deviceId,
        'sequence': sequence,
        'timestamp': timestamp.toUtc().toIso8601String(),
        'operations': operations.map((op) => op.toJson()).toList(),
      };

  factory Changeset.fromJson(Map<String, dynamic> json) => Changeset(
        deviceId: json['device_id'] as String,
        sequence: json['sequence'] as int,
        timestamp: DateTime.parse(json['timestamp'] as String),
        operations: (json['operations'] as List)
            .map((e) => SyncOperation.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

enum OpType { insert, update, delete }

/// A single INSERT, UPDATE, or DELETE operation within a changeset.
class SyncOperation {
  final OpType op;
  final String table;
  final String id;
  final Map<String, dynamic>? data;
  final Map<String, dynamic>? prev;
  final DateTime? deletedAt;

  SyncOperation({
    required this.op,
    required this.table,
    required this.id,
    this.data,
    this.prev,
    this.deletedAt,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'op': op.name.toUpperCase(),
      'table': table,
      'id': id,
    };
    if (data != null) json['data'] = data;
    if (prev != null) json['prev'] = prev;
    if (deletedAt != null) {
      json['deleted_at'] = deletedAt!.toUtc().toIso8601String();
    }
    return json;
  }

  factory SyncOperation.fromJson(Map<String, dynamic> json) => SyncOperation(
        op: OpType.values.firstWhere(
          (e) => e.name.toUpperCase() == json['op'],
        ),
        table: json['table'] as String,
        id: json['id'] as String,
        data: json['data'] as Map<String, dynamic>?,
        prev: json['prev'] as Map<String, dynamic>?,
        deletedAt: json['deleted_at'] != null
            ? DateTime.parse(json['deleted_at'] as String)
            : null,
      );
}
