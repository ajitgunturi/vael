import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vael/core/providers/session_providers.dart';

void main() {
  group('SessionProviders', () {
    test('sessionFamilyIdProvider defaults to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(sessionFamilyIdProvider), isNull);
    });

    test('sessionUserIdProvider defaults to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(sessionUserIdProvider), isNull);
    });

    test('sessionFamilyIdProvider can be set via notifier', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(sessionFamilyIdProvider.notifier).set('fam_123');
      expect(container.read(sessionFamilyIdProvider), 'fam_123');
    });

    test('sessionUserIdProvider can be set via notifier', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(sessionUserIdProvider.notifier).set('user_123');
      expect(container.read(sessionUserIdProvider), 'user_123');
    });
  });
}
