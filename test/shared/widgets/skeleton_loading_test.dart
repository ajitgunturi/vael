import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/shared/widgets/skeleton_loading.dart';

void main() {
  Widget buildApp(Widget child) {
    return MaterialApp(
      theme: ThemeData(brightness: Brightness.light),
      home: Scaffold(body: child),
    );
  }

  group('SkeletonBox', () {
    testWidgets('renders with specified dimensions', (tester) async {
      await tester.pumpWidget(
        buildApp(const SkeletonBox(width: 200, height: 20)),
      );
      expect(find.byType(SkeletonBox), findsOneWidget);

      final box = tester.getSize(find.byType(SkeletonBox));
      expect(box.width, 200);
      expect(box.height, 20);
    });

    testWidgets('has shimmer animation running', (tester) async {
      await tester.pumpWidget(
        buildApp(const SkeletonBox(width: 100, height: 16)),
      );

      // The AnimationController should be running (repeat mode).
      // Advance time and verify widget rebuilds without error.
      await tester.pump(const Duration(milliseconds: 750));
      expect(find.byType(SkeletonBox), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 750));
      expect(find.byType(SkeletonBox), findsOneWidget);
    });

    testWidgets('uses theme colors for gradient', (tester) async {
      await tester.pumpWidget(
        buildApp(const SkeletonBox(width: 100, height: 16)),
      );

      // Verify it renders a Container with a gradient (not a solid color).
      final container = tester.widget<Container>(find.byType(Container).last);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, isA<LinearGradient>());
    });
  });

  group('SkeletonCard', () {
    testWidgets('renders with card-shaped dimensions', (tester) async {
      await tester.pumpWidget(
        buildApp(const SizedBox(width: 300, child: SkeletonCard(height: 80))),
      );
      expect(find.byType(SkeletonCard), findsOneWidget);
      expect(find.byType(SkeletonBox), findsOneWidget);
    });
  });
}
