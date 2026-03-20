/// Immutable result of a successful Google Sign-In.
///
/// Holds the minimum credentials needed for Drive sync without
/// exposing the full [GoogleSignInAccount] to the rest of the app.
class GoogleAuthResult {
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String accessToken;

  const GoogleAuthResult({
    required this.email,
    required this.displayName,
    this.avatarUrl,
    required this.accessToken,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoogleAuthResult &&
          runtimeType == other.runtimeType &&
          email == other.email &&
          displayName == other.displayName &&
          avatarUrl == other.avatarUrl &&
          accessToken == other.accessToken;

  @override
  int get hashCode => Object.hash(email, displayName, avatarUrl, accessToken);

  @override
  String toString() =>
      'GoogleAuthResult(email: $email, displayName: $displayName)';
}
