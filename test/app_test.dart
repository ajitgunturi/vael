import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/app.dart';

void main() {
  group('VaelApp', () {
    testWidgets('uses AppTheme.light() as theme', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: VaelApp()));
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.theme, isNotNull);
      expect(app.theme!.brightness, Brightness.light);
    });

    testWidgets('uses AppTheme.dark() as darkTheme', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: VaelApp()));
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.darkTheme, isNotNull);
      expect(app.darkTheme!.brightness, Brightness.dark);
    });

    testWidgets('uses ThemeMode.system', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: VaelApp()));
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.system);
    });

    testWidgets('shows placeholder when no session is set', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: VaelApp()));
      await tester.pumpAndSettle();
      // No familyId/userId means we show the placeholder, not HomeShell
      expect(find.text('Vael'), findsOneWidget);
    });
  });
}
