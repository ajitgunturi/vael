import 'package:google_sign_in/google_sign_in.dart';

import 'google_auth_result.dart';

/// Exception thrown when auth headers are requested without an active session.
class NotSignedInException implements Exception {
  @override
  String toString() => 'NotSignedInException: No active Google session.';
}

/// Thin wrapper around [GoogleSignIn] that exposes only the surface area
/// Vael needs: sign-in, sign-out, auth headers for Drive, and session state.
///
/// Accepts [GoogleSignIn] via constructor injection so tests can substitute
/// a mock without code-gen.
class GoogleAuthService {
  final GoogleSignIn _googleSignIn;
  GoogleSignInAccount? _currentAccount;

  GoogleAuthService({GoogleSignIn? googleSignIn})
    : _googleSignIn =
          googleSignIn ??
          GoogleSignIn(
            scopes: ['email', 'https://www.googleapis.com/auth/drive.file'],
          );

  /// Whether a user is currently signed in.
  bool get isSignedIn => _currentAccount != null;

  /// Initiates the Google sign-in flow.
  ///
  /// Returns a [GoogleAuthResult] on success, or `null` if the user cancels.
  /// Throws on unexpected platform errors.
  Future<GoogleAuthResult?> signIn() async {
    final account = await _googleSignIn.signIn();
    if (account == null) return null;

    _currentAccount = account;
    final auth = await account.authentication;

    return GoogleAuthResult(
      email: account.email,
      displayName: account.displayName ?? '',
      avatarUrl: account.photoUrl,
      accessToken: auth.accessToken ?? '',
    );
  }

  /// Signs out the current user and clears local session state.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentAccount = null;
  }

  /// Returns HTTP headers (including `Authorization: Bearer ...`) for the
  /// currently signed-in account.
  ///
  /// Throws [NotSignedInException] if no session is active.
  Future<Map<String, String>> getAuthHeaders() async {
    final account = _currentAccount;
    if (account == null) throw NotSignedInException();
    return await account.authHeaders;
  }
}
