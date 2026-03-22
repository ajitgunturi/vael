import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database_path.dart';

void main() {
  group('databaseFileName', () {
    test('returns a fixed opaque hex string', () {
      final name = databaseFileName();
      // SHA-256 of 'vael_family_finance' → 64-char hex + .db
      expect(name, matches(RegExp(r'^[0-9a-f]{64}\.db$')));
    });

    test('is deterministic across calls', () {
      expect(databaseFileName(), equals(databaseFileName()));
    });

    test('does not contain identifiable words', () {
      final name = databaseFileName();
      expect(name.contains('vael'), isFalse);
      expect(name.contains('finance'), isFalse);
      expect(name.contains('family'), isFalse);
      expect(name.contains('budget'), isFalse);
    });
  });
}
