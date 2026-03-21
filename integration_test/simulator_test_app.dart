import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:vael/core/database/database.dart';
import 'package:vael/core/providers/database_providers.dart';
import 'package:vael/features/accounts/screens/account_list_screen.dart';
import 'package:vael/features/budgets/screens/budget_screen.dart';
import 'package:vael/features/dashboard/screens/dashboard_screen.dart';
import 'package:vael/features/transactions/screens/transaction_list_screen.dart';
import 'package:vael/shared/layout/adaptive_scaffold.dart';
import 'package:vael/shared/theme/app_theme.dart';

/// Test family / user constants used across all simulator tests.
const kTestFamilyId = 'sim_family';
const kTestUserId = 'user_sim_family';

/// Seeds the minimum required FK rows (family + user) so that all
/// downstream inserts (accounts, transactions, budgets) succeed.
Future<void> seedTestFamily(AppDatabase db) async {
  await db.into(db.families).insert(
    FamiliesCompanion.insert(
      id: kTestFamilyId,
      name: 'Simulator Family',
      createdAt: DateTime(2025),
    ),
  );
  await db.into(db.users).insert(
    UsersCompanion.insert(
      id: kTestUserId,
      email: 'sim@test.com',
      displayName: 'Sim User',
      role: 'admin',
      familyId: kTestFamilyId,
    ),
  );
}

/// A fully-wired test app that mirrors the eventual production navigation.
///
/// Uses [AdaptiveScaffold] with all 5 tabs: Dashboard, Accounts,
/// Transactions, Budget, Goals. Backed by an in-memory drift database
/// so every test run starts clean.
class SimulatorTestApp extends StatefulWidget {
  const SimulatorTestApp({super.key, required this.db});

  final AppDatabase db;

  @override
  State<SimulatorTestApp> createState() => _SimulatorTestAppState();
}

class _SimulatorTestAppState extends State<SimulatorTestApp> {
  int _selectedIndex = 0;

  Widget _bodyForIndex(int index) {
    final now = DateTime.now();
    return switch (index) {
      0 => const DashboardScreen(familyId: kTestFamilyId),
      1 => const AccountListScreen(familyId: kTestFamilyId),
      2 => const TransactionListScreen(
          familyId: kTestFamilyId,
          userId: kTestUserId,
        ),
      3 => BudgetScreen(
          familyId: kTestFamilyId,
          year: now.year,
          month: now.month,
        ),
      4 => const Center(child: Text('Goals — coming soon')),
      _ => const SizedBox.shrink(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [databaseProvider.overrideWithValue(widget.db)],
      child: MaterialApp(
        title: 'Vael Simulator Tests',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.light,
        home: AdaptiveScaffold(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (i) => setState(() => _selectedIndex = i),
          body: _bodyForIndex(_selectedIndex),
        ),
      ),
    );
  }
}
