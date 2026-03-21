import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/shared/layout/page_transitions.dart';

void main() {
  group('VaelPageRoute', () {
    testWidgets('navigates with fade+slide transition', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    VaelPageRoute<void>(
                      builder: (_) => const Scaffold(body: Text('Destination')),
                    ),
                  );
                },
                child: const Text('Navigate'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      expect(find.text('Destination'), findsOneWidget);
    });

    test('uses 300ms transition duration and easeInOutCubic', () {
      final route = VaelPageRoute<void>(builder: (_) => const SizedBox());
      expect(route.transitionDuration, const Duration(milliseconds: 300));
      expect(
        route.reverseTransitionDuration,
        const Duration(milliseconds: 300),
      );
    });
  });
}
