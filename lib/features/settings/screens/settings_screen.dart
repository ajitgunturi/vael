import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/session_providers.dart';
import '../../../shared/theme/spacing.dart';
import 'passphrase_setup_screen.dart';

/// Settings hub — entry point for all app configuration screens.
///
/// Presents a list of navigable sections: Family Backup, Sync Status,
/// Passphrase, and Sign Out. Sign-out clears both session providers,
/// which reactively returns the user to the onboarding flow via [VaelApp].
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({
    super.key,
    required this.familyId,
    required this.userId,
  });

  final String familyId;
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const SizedBox(height: Spacing.sm),
          _SettingsTile(
            icon: Icons.folder_shared,
            title: 'Family Backup',
            subtitle: 'Manage cloud backup and members',
            onTap: () => _openFamilyBackup(context),
          ),
          _SettingsTile(
            icon: Icons.sync,
            title: 'Sync Status',
            subtitle: 'View sync engine status',
            onTap: () => _openSyncStatus(context),
          ),
          _SettingsTile(
            icon: Icons.lock,
            title: 'Passphrase',
            subtitle: 'Set or change family passphrase',
            onTap: () => _openPassphrase(context),
          ),
          const Divider(),
          _SettingsTile(
            icon: Icons.logout,
            title: 'Sign Out',
            subtitle: 'Clear session and return to onboarding',
            onTap: () => _signOut(context, ref),
          ),
          const Divider(),
          const _AppInfoSection(),
        ],
      ),
    );
  }

  void _openFamilyBackup(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Family Backup')),
          body: const Center(child: Text('Connect cloud storage to enable.')),
        ),
      ),
    );
  }

  void _openSyncStatus(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Sync Status')),
          body: const Center(child: Text('No sync configured.')),
        ),
      ),
    );
  }

  void _openPassphrase(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PassphraseSetupScreen(
          onSetup: (_) {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _signOut(BuildContext context, WidgetRef ref) {
    ref.read(sessionFamilyIdProvider.notifier).set(null);
    ref.read(sessionUserIdProvider.notifier).set(null);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _AppInfoSection extends StatelessWidget {
  const _AppInfoSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        children: [
          Text('Vael', style: theme.textTheme.titleMedium),
          const SizedBox(height: Spacing.xs),
          Text(
            'Privacy-first family finance',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
