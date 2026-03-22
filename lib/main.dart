import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/database/database.dart';
import 'core/providers/database_providers.dart';
import 'core/providers/session_providers.dart';

/// Dev-mode family/user constants for bootstrapping without onboarding.
const kDevFamilyId = 'dev_family';
const kDevUserId = 'dev_user';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: _AppRoot()));
}

/// Root widget that seeds dev data in debug mode before showing the app.
class _AppRoot extends ConsumerStatefulWidget {
  const _AppRoot();

  @override
  ConsumerState<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<_AppRoot> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      _seedDevData();
    } else {
      _ready = true;
    }
  }

  Future<void> _seedDevData() async {
    final db = ref.read(databaseProvider);
    await db
        .into(db.families)
        .insertOnConflictUpdate(
          FamiliesCompanion.insert(
            id: kDevFamilyId,
            name: 'Dev Family',
            createdAt: DateTime(2025),
          ),
        );
    await db
        .into(db.users)
        .insertOnConflictUpdate(
          UsersCompanion.insert(
            id: kDevUserId,
            email: 'dev@vael.app',
            displayName: 'Dev User',
            role: 'admin',
            familyId: kDevFamilyId,
          ),
        );
    ref.read(sessionFamilyIdProvider.notifier).set(kDevFamilyId);
    ref.read(sessionUserIdProvider.notifier).set(kDevUserId);
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return const VaelApp();
  }
}
