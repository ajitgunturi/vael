import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/crypto/key_storage.dart';

void main() {
  group('KeyStorage', () {
    late KeyStorage keyStorage;

    setUp(() {
      keyStorage = KeyStorage(storage: InMemorySecureStorage());
    });

    test('stores and retrieves FEK by family ID', () async {
      final fek = Uint8List.fromList(List.generate(32, (i) => i));

      await keyStorage.storeFek('family-123', fek);
      final retrieved = await keyStorage.getFek('family-123');

      expect(retrieved, equals(fek));
    });

    test('returns null for missing family ID', () async {
      final result = await keyStorage.getFek('nonexistent');
      expect(result, isNull);
    });

    test('deletes stored FEK', () async {
      final fek = Uint8List.fromList(List.generate(32, (i) => i));

      await keyStorage.storeFek('family-123', fek);
      await keyStorage.deleteFek('family-123');
      final result = await keyStorage.getFek('family-123');

      expect(result, isNull);
    });

    test('overwrites existing FEK for same family ID', () async {
      final fek1 = Uint8List.fromList(List.generate(32, (i) => i));
      final fek2 = Uint8List.fromList(List.generate(32, (i) => i + 100));

      await keyStorage.storeFek('family-123', fek1);
      await keyStorage.storeFek('family-123', fek2);
      final retrieved = await keyStorage.getFek('family-123');

      expect(retrieved, equals(fek2));
    });

    test('namespaced by family ID — different families isolated', () async {
      final fek1 = Uint8List.fromList(List.generate(32, (i) => i));
      final fek2 = Uint8List.fromList(List.generate(32, (i) => i + 50));

      await keyStorage.storeFek('family-A', fek1);
      await keyStorage.storeFek('family-B', fek2);

      expect(await keyStorage.getFek('family-A'), equals(fek1));
      expect(await keyStorage.getFek('family-B'), equals(fek2));
    });

    test('hasFek returns true when stored, false otherwise', () async {
      expect(await keyStorage.hasFek('family-123'), false);

      await keyStorage.storeFek(
          'family-123', Uint8List.fromList(List.generate(32, (i) => i)));

      expect(await keyStorage.hasFek('family-123'), true);
    });
  });
}
