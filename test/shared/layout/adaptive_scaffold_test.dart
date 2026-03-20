import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/shared/layout/adaptive_scaffold.dart';
import 'package:vael/shared/layout/breakpoints.dart';

void main() {
  group('Breakpoints', () {
    test('compact threshold should be 600', () {
      expect(Breakpoints.compact, 600.0);
    });

    test('medium threshold should be 900', () {
      expect(Breakpoints.medium, 900.0);
    });

    test('isCompact should return true for width below 600', () {
      expect(Breakpoints.isCompact(400), isTrue);
      expect(Breakpoints.isCompact(599.9), isTrue);
      expect(Breakpoints.isCompact(600), isFalse);
    });

    test('isMedium should return true for width between 600 and 900', () {
      expect(Breakpoints.isMedium(600), isTrue);
      expect(Breakpoints.isMedium(750), isTrue);
      expect(Breakpoints.isMedium(899.9), isTrue);
      expect(Breakpoints.isMedium(900), isFalse);
      expect(Breakpoints.isMedium(400), isFalse);
    });

    test('isExpanded should return true for width 900 and above', () {
      expect(Breakpoints.isExpanded(900), isTrue);
      expect(Breakpoints.isExpanded(1200), isTrue);
      expect(Breakpoints.isExpanded(899.9), isFalse);
    });
  });

  group('AdaptiveScaffold', () {
    Widget buildTestHarness({
      required double width,
      int selectedIndex = 0,
      ValueChanged<int>? onDestinationSelected,
    }) {
      return MaterialApp(
        home: Center(
          child: SizedBox(
            width: width,
            height: 800,
            child: AdaptiveScaffold(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected ?? (_) {},
              body: const Text('body'),
            ),
          ),
        ),
      );
    }

    group('at 400dp width (compact — phone portrait)', () {
      testWidgets('should render BottomNavigationBar', (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestHarness(width: 400));

        expect(find.byType(BottomNavigationBar), findsOneWidget);
        expect(find.byType(NavigationRail), findsNothing);
      });

      testWidgets('should have 6 navigation items', (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestHarness(width: 400));

        final bottomNav = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar),
        );
        expect(bottomNav.items.length, 6);
      });

      testWidgets('should reflect selected index', (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          buildTestHarness(width: 400, selectedIndex: 2),
        );

        final bottomNav = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar),
        );
        expect(bottomNav.currentIndex, 2);
      });

      testWidgets('should call onDestinationSelected when tapped',
          (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        int? tappedIndex;
        await tester.pumpWidget(buildTestHarness(
          width: 400,
          onDestinationSelected: (i) => tappedIndex = i,
        ));

        await tester.tap(find.byIcon(Icons.pie_chart));
        expect(tappedIndex, 3);
      });
    });

    group('at 750dp width (medium — tablet portrait)', () {
      testWidgets('should render NavigationRail', (tester) async {
        tester.view.physicalSize = const Size(750, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestHarness(width: 750));

        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.byType(BottomNavigationBar), findsNothing);
      });

      testWidgets('should have 6 destinations', (tester) async {
        tester.view.physicalSize = const Size(750, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestHarness(width: 750));

        final rail = tester.widget<NavigationRail>(
          find.byType(NavigationRail),
        );
        expect(rail.destinations.length, 6);
      });

      testWidgets('should reflect selected index', (tester) async {
        tester.view.physicalSize = const Size(750, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          buildTestHarness(width: 750, selectedIndex: 4),
        );

        final rail = tester.widget<NavigationRail>(
          find.byType(NavigationRail),
        );
        expect(rail.selectedIndex, 4);
      });
    });

    group('at 1200dp width (expanded — landscape iPad/Mac)', () {
      testWidgets('should render persistent drawer with ListTiles',
          (tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestHarness(width: 1200));

        expect(find.byType(ListTile), findsNWidgets(6));
        expect(find.byType(BottomNavigationBar), findsNothing);
        expect(find.byType(NavigationRail), findsNothing);
      });

      testWidgets('should show all 6 labels', (tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestHarness(width: 1200));

        expect(find.text('Dashboard'), findsOneWidget);
        expect(find.text('Accounts'), findsOneWidget);
        expect(find.text('Transactions'), findsOneWidget);
        expect(find.text('Budget'), findsOneWidget);
        expect(find.text('Goals'), findsOneWidget);
        expect(find.text('Settings'), findsOneWidget);
      });

      testWidgets('should call onDestinationSelected when tapped',
          (tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        int? tappedIndex;
        await tester.pumpWidget(buildTestHarness(
          width: 1200,
          onDestinationSelected: (i) => tappedIndex = i,
        ));

        await tester.tap(find.text('Settings'));
        expect(tappedIndex, 5);
      });
    });

    testWidgets('should render the body widget', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestHarness(width: 400));
      expect(find.text('body'), findsOneWidget);
    });
  });
}
