import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier for the active family ID in the current session.
class SessionFamilyIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? id) => state = id;
}

/// Holds the active family ID for the current session.
///
/// Null when no family is set (fresh install / signed out).
/// Set after onboarding completes or session is restored.
final sessionFamilyIdProvider =
    NotifierProvider<SessionFamilyIdNotifier, String?>(
      SessionFamilyIdNotifier.new,
    );

/// Notifier for the active user ID in the current session.
class SessionUserIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? id) => state = id;
}

/// Holds the active user ID for the current session.
///
/// Null when no user is set (fresh install / signed out).
final sessionUserIdProvider = NotifierProvider<SessionUserIdNotifier, String?>(
  SessionUserIdNotifier.new,
);
