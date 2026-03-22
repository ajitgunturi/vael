import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/accounts/screens/account_list_screen.dart';
import '../../features/budgets/screens/budget_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/transactions/screens/transaction_list_screen.dart';
import '../layout/adaptive_scaffold.dart';

/// Production app shell that wires [AdaptiveScaffold] with all feature screens.
///
/// Manages the selected tab index and passes the correct screen body
/// based on tab selection. Requires a valid [familyId] and [userId]
/// from the session layer.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key, required this.familyId, required this.userId});

  final String familyId;
  final String userId;

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _selectedIndex = 0;

  void _onNavigateToTab(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget _bodyForIndex(int index) {
    final now = DateTime.now();
    return switch (index) {
      0 => DashboardScreen(
        familyId: widget.familyId,
        onNavigateToTab: _onNavigateToTab,
      ),
      1 => AccountListScreen(familyId: widget.familyId),
      2 => TransactionListScreen(
        familyId: widget.familyId,
        userId: widget.userId,
      ),
      3 => BudgetScreen(
        familyId: widget.familyId,
        year: now.year,
        month: now.month,
      ),
      4 => const Center(child: Text('Goals')),
      _ => const SizedBox.shrink(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onNavigateToTab,
      body: _bodyForIndex(_selectedIndex),
      onSettingsTap: () {
        // Settings navigation wired in Wave 4.
      },
    );
  }
}
