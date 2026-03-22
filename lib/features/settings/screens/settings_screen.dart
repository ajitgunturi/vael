import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:typed_data';

import '../../../core/providers/session_providers.dart';
import '../../../core/sync/manifest.dart';
import '../../../core/sync/sync_orchestrator.dart';
import '../../../shared/theme/spacing.dart';
import '../../../shared/theme/theme_mode_provider.dart';
import '../../planning/providers/life_profile_provider.dart';
import '../../planning/screens/life_profile_wizard_screen.dart';
import 'category_management_screen.dart';
import 'family_backup_screen.dart';
import 'passphrase_setup_screen.dart';
import 'sync_status_screen.dart';

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
            icon: Icons.category,
            title: 'Categories',
            subtitle: 'Manage expense and income categories',
            onTap: () => _openCategories(context),
          ),
          _SettingsTile(
            icon: Icons.lock,
            title: 'Passphrase',
            subtitle: 'Set or change family passphrase',
            onTap: () => _openPassphrase(context),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 8, bottom: 4),
            child: Text(
              'Financial Planning',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          _SettingsTile(
            icon: Icons.person_outline,
            title: 'Life Profile',
            subtitle: 'Age, retirement, risk & growth rates',
            onTap: () => _openLifeProfile(context, ref),
          ),
          const Divider(),
          _ThemeModeTile(ref: ref),
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

  void _openLifeProfile(BuildContext context, WidgetRef ref) {
    // Read current profile to determine edit vs create mode.
    final profileAsync = ref.read(
      lifeProfileProvider((userId: userId, familyId: familyId)),
    );
    final existing = profileAsync.whenOrNull(data: (p) => p);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LifeProfileWizardScreen(
          userId: userId,
          familyId: familyId,
          existingProfile: existing,
        ),
      ),
    );
  }

  void _openCategories(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryManagementScreen(familyId: familyId),
      ),
    );
  }

  void _openFamilyBackup(BuildContext context) {
    final currentMember = MemberEntry(
      userId: userId,
      email: '$userId@family.local',
      role: 'admin',
      wrappedFek: Uint8List(0),
      fekSalt: Uint8List(0),
      addedAt: DateTime.now(),
      addedBy: userId,
      status: MemberStatus.active,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FamilyBackupScreen(
          manifestStatus: ManifestStatus(
            memberCount: 1,
            isAdmin: true,
            fekGeneration: 1,
            ownerEmail: currentMember.email,
            members: [currentMember],
          ),
          syncStatus: SyncStatus(deviceId: 'this-device', pendingChanges: 0),
          currentUserId: userId,
          onAddMember: () {},
          onTransferOwnership: () {},
          onCreateBackup: () {},
          onRemoveMember: (_) {},
        ),
      ),
    );
  }

  void _openSyncStatus(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SyncStatusScreen(
          status: SyncStatus(deviceId: 'this-device', pendingChanges: 0),
          onPushNow: () {},
          onPullNow: () {},
          onCreateBackup: () {},
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

class _ThemeModeTile extends StatelessWidget {
  const _ThemeModeTile({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final themeModeAsync = ref.watch(themeModeProvider);
    final current = switch (themeModeAsync) {
      AsyncData(:final value) => value,
      _ => ThemeMode.system,
    };

    final icon = switch (current) {
      ThemeMode.light => Icons.light_mode,
      ThemeMode.dark => Icons.dark_mode,
      ThemeMode.system => Icons.brightness_auto,
    };
    final label = switch (current) {
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
      ThemeMode.system => 'System',
    };

    return ListTile(
      leading: Icon(icon),
      title: const Text('Appearance'),
      subtitle: Text(label),
      trailing: SegmentedButton<ThemeMode>(
        segments: const [
          ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode)),
          ButtonSegment(
            value: ThemeMode.system,
            icon: Icon(Icons.brightness_auto),
          ),
          ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode)),
        ],
        selected: {current},
        onSelectionChanged: (s) {
          ref.read(themeModeProvider.notifier).setMode(s.first);
        },
      ),
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
