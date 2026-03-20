import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vael/core/auth/google_auth_result.dart';
import 'package:vael/core/auth/google_auth_service.dart';

// ---------------------------------------------------------------------------
// Manual mocks — avoids mockito code-gen while staying dependency-injectable.
// ---------------------------------------------------------------------------

class MockGoogleSignInAuthentication implements GoogleSignInAuthentication {
  @override
  final String? accessToken;
  @override
  final String? idToken;
  @override
  final String? serverAuthCode;

  MockGoogleSignInAuthentication({
    this.accessToken = 'mock-access-token',
    this.idToken,
    this.serverAuthCode,
  });
}

class MockGoogleSignInAccount implements GoogleSignInAccount {
  @override
  final String email;
  @override
  final String? displayName;
  @override
  final String id;
  @override
  final String? photoUrl;
  @override
  final String? serverAuthCode;

  final MockGoogleSignInAuthentication _auth;
  final Map<String, String> _authHeaders;

  MockGoogleSignInAccount({
    this.email = 'test@example.com',
    this.displayName = 'Test User',
    this.id = '123',
    this.photoUrl = 'https://photo.url/avatar.png',
    this.serverAuthCode,
    MockGoogleSignInAuthentication? auth,
    Map<String, String>? authHeaders,
  })  : _auth = auth ?? MockGoogleSignInAuthentication(),
        _authHeaders = authHeaders ??
            {'Authorization': 'Bearer mock-access-token'};

  @override
  Future<GoogleSignInAuthentication> get authentication async => _auth;

  @override
  Future<Map<String, String>> get authHeaders async => _authHeaders;

  @override
  Future<void> clearAuthCache() async {}
}

class MockGoogleSignIn implements GoogleSignIn {
  MockGoogleSignInAccount? accountToReturn;
  bool signOutCalled = false;
  bool shouldThrowOnSignIn = false;
  String? errorMessage;

  @override
  Future<GoogleSignInAccount?> signIn() async {
    if (shouldThrowOnSignIn) {
      throw Exception(errorMessage ?? 'Sign-in failed');
    }
    return accountToReturn;
  }

  @override
  Future<GoogleSignInAccount?> signOut() async {
    signOutCalled = true;
    return null;
  }

  // --- Stubs for the rest of the GoogleSignIn interface ---

  @override
  Future<GoogleSignInAccount?> signInSilently({
    bool suppressErrors = true,
    bool reAuthenticate = false,
  }) async =>
      null;

  @override
  Future<GoogleSignInAccount?> disconnect() async => null;

  @override
  Future<bool> isSignedIn() async => accountToReturn != null;

  @override
  Future<bool> canAccessScopes(List<String> scopes,
          {String? accessToken}) async =>
      true;

  @override
  Future<bool> requestScopes(List<String> scopes) async => true;

  @override
  GoogleSignInAccount? get currentUser => accountToReturn;

  @override
  Stream<GoogleSignInAccount?> get onCurrentUserChanged =>
      const Stream.empty();

  @override
  String? get serverClientId => null;

  @override
  bool get forceCodeForRefreshToken => false;

  @override
  List<String> get scopes => ['email'];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockGoogleSignIn mockGoogleSignIn;
  late GoogleAuthService service;

  setUp(() {
    mockGoogleSignIn = MockGoogleSignIn();
    service = GoogleAuthService(googleSignIn: mockGoogleSignIn);
  });

  group('GoogleAuthResult', () {
    test('should be value-equal when all fields match', () {
      const a = GoogleAuthResult(
        email: 'a@b.com',
        displayName: 'A',
        accessToken: 'tok',
      );
      const b = GoogleAuthResult(
        email: 'a@b.com',
        displayName: 'A',
        accessToken: 'tok',
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('should not equal when fields differ', () {
      const a = GoogleAuthResult(
        email: 'a@b.com',
        displayName: 'A',
        accessToken: 'tok1',
      );
      const b = GoogleAuthResult(
        email: 'a@b.com',
        displayName: 'A',
        accessToken: 'tok2',
      );
      expect(a, isNot(equals(b)));
    });
  });

  group('GoogleAuthService.signIn', () {
    test(
        'should return GoogleAuthResult with email, displayName, accessToken '
        'on success', () async {
      mockGoogleSignIn.accountToReturn = MockGoogleSignInAccount(
        email: 'ajit@example.com',
        displayName: 'Ajit',
        photoUrl: 'https://photo.url/avatar.png',
        auth: MockGoogleSignInAuthentication(accessToken: 'real-token'),
      );

      final result = await service.signIn();

      expect(result, isNotNull);
      expect(result!.email, 'ajit@example.com');
      expect(result.displayName, 'Ajit');
      expect(result.avatarUrl, 'https://photo.url/avatar.png');
      expect(result.accessToken, 'real-token');
    });

    test('should return null when user cancels sign-in', () async {
      mockGoogleSignIn.accountToReturn = null;

      final result = await service.signIn();

      expect(result, isNull);
    });

    test('should throw when sign-in encounters a platform error', () async {
      mockGoogleSignIn.shouldThrowOnSignIn = true;
      mockGoogleSignIn.errorMessage = 'network error';

      expect(() => service.signIn(), throwsException);
    });
  });

  group('GoogleAuthService.signOut', () {
    test('should clear auth state after sign-out', () async {
      mockGoogleSignIn.accountToReturn = MockGoogleSignInAccount();
      await service.signIn();
      expect(service.isSignedIn, isTrue);

      await service.signOut();

      expect(service.isSignedIn, isFalse);
      expect(mockGoogleSignIn.signOutCalled, isTrue);
    });
  });

  group('GoogleAuthService.getAuthHeaders', () {
    test('should return valid headers when signed in', () async {
      mockGoogleSignIn.accountToReturn = MockGoogleSignInAccount(
        authHeaders: {'Authorization': 'Bearer my-token'},
      );
      await service.signIn();

      final headers = await service.getAuthHeaders();

      expect(headers, containsPair('Authorization', 'Bearer my-token'));
    });

    test('should throw NotSignedInException when not signed in', () async {
      expect(
        () => service.getAuthHeaders(),
        throwsA(isA<NotSignedInException>()),
      );
    });
  });

  group('GoogleAuthService.isSignedIn', () {
    test('should return false initially', () {
      expect(service.isSignedIn, isFalse);
    });

    test('should return true after successful sign-in', () async {
      mockGoogleSignIn.accountToReturn = MockGoogleSignInAccount();
      await service.signIn();
      expect(service.isSignedIn, isTrue);
    });

    test('should return false after sign-out', () async {
      mockGoogleSignIn.accountToReturn = MockGoogleSignInAccount();
      await service.signIn();
      await service.signOut();
      expect(service.isSignedIn, isFalse);
    });

    test('should remain false when sign-in is cancelled', () async {
      mockGoogleSignIn.accountToReturn = null;
      await service.signIn();
      expect(service.isSignedIn, isFalse);
    });
  });
}
