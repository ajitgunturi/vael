import 'package:flutter/material.dart';

import 'breakpoints.dart';

class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    this.onSettingsTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final VoidCallback? onSettingsTap;

  /// 5 primary destinations (Settings removed — moved to AppBar gear icon).
  static const destinations = <NavigationDestinationData>[
    NavigationDestinationData(icon: Icons.dashboard, label: 'Dashboard'),
    NavigationDestinationData(icon: Icons.account_balance, label: 'Accounts'),
    NavigationDestinationData(icon: Icons.receipt_long, label: 'Transactions'),
    NavigationDestinationData(icon: Icons.pie_chart, label: 'Budget'),
    NavigationDestinationData(icon: Icons.flag, label: 'Goals'),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (Breakpoints.isCompact(width)) {
          return _buildCompact();
        } else if (Breakpoints.isMedium(width)) {
          return _buildMedium();
        } else {
          return _buildExpanded();
        }
      },
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      actions: [
        if (onSettingsTap != null)
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: onSettingsTap,
            tooltip: 'Settings',
          ),
      ],
    );
  }

  Widget _buildCompact() {
    return Scaffold(
      appBar: _appBar(),
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onDestinationSelected,
        type: BottomNavigationBarType.fixed,
        items: [
          for (final d in destinations)
            BottomNavigationBarItem(icon: Icon(d.icon), label: d.label),
        ],
      ),
    );
  }

  Widget _buildMedium() {
    return Scaffold(
      appBar: _appBar(),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            destinations: [
              for (final d in destinations)
                NavigationRailDestination(
                  icon: Icon(d.icon),
                  label: Text(d.label),
                ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }

  Widget _buildExpanded() {
    return Scaffold(
      appBar: _appBar(),
      body: Row(
        children: [
          SizedBox(
            width: 280,
            child: Material(
              child: ListView(
                children: [
                  const SizedBox(height: 16),
                  for (var i = 0; i < destinations.length; i++)
                    ListTile(
                      leading: Icon(destinations[i].icon),
                      title: Text(destinations[i].label),
                      selected: i == selectedIndex,
                      onTap: () => onDestinationSelected(i),
                    ),
                ],
              ),
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class NavigationDestinationData {
  const NavigationDestinationData({required this.icon, required this.label});
  final IconData icon;
  final String label;
}
