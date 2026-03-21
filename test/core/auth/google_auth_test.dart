import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vael/core/auth/google_auth_result.dart';
import 'package:vael/core/auth/google_auth_service.dart';

// ---------------------------------------------------------------------------
// Manual mocks — avoids mockito code-gen while staying dependency-injectable.
// ---------------------------------------------------------------------------

class MockGoogleSignInClientAuthorization
    implements GoogleSignInClientAuthorization {
  @override
  final String accessToken;

  MockGoogleSignInClientAuthorization({this.accessToken = 'mock-access-token'});
}

class MockGoogleSignInAuthorizationClient
    implements GoogleSignInAuthorizationClient {
  final String accessToken;
  final Map<String, String>? _headers;

  MockGoogleSignInAuthorizationClient({
    this.accessToken = 'mock-access-token',
    Map<String, String>? headers,
  }) : _headers = headers;

  @override
  Future<GoogleSignInClientAuthorization?> authorizationForScopes(
    List<String> scopes,
  ) async => MockGoogleSignInClientAuthorization(accessToken: accessToken);

  @override
  Future<GoogleSignInClientAuthorization> authorizeScopes(
    List<String> scopes,
  ) async => MockGoogleSignInClientAuthorization(accessToken: accessToken);

  @override
  Future<Map<String, String>?> authorizationHeaders(
    List<String> scopes, {
    bool promptIfNecessary = false,
  }) async => _headers ?? {'Authorization': 'Bearer $accessToken'};

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockGoogleSignInAuthentication implements GoogleSignInAuthentication {
  @override
  final String? idToken;

  MockGoogleSignInAuthentication({this.idToken});
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

  final MockGoogleSignInAuthorizationClient _authzClient;

  MockGoogleSignInAccount({
    this.email = 'test@example.com',
    this.displayName = 'Test User',
    this.id = '123',
    this.photoUrl = 'https://photo.url/avatar.png',
    String accessToken = 'mock-access-token',
    Map<String, String>? authHeaders,
  }) : _authzClient = MockGoogleSignInAuthorizationClient(
         accessToken: accessToken,
         headers: authHeaders,
       );

  @override
  GoogleSignInAuthentication get authentication =>
      MockGoogleSignInAuthentication();

  @override
  GoogleSignInAuthorizationClient get authorizationClient => _authzClient;
}

class MockGoogleSignIn implements GoogleSignIn {
  MockGoogleSignInAccount? accountToReturn;
  bool signOutCalled = false;
  bool shouldThrowOnSignIn = false;
  String? errorMessage;

  @override
  Future<GoogleSignInAccount> authenticate({
    List<String> scopeHint = const <String>[],
  }) async {
    if (shouldThrowOnSignIn) {
      throw Exception(errorMessage ?? 'Sign-in failed');
    }
    if (accountToReturn == null) {
      throw const GoogleSignInException(
        code: GoogleSignInExceptionCode.canceled,
      );
    }
    return accountToReturn!;
  }

  @override
  Future<void> signOut() async {
    signOutCalled = true;
  }

  // --- Stubs for the rest of the GoogleSignIn interface ---

  @override
  Future<GoogleSignInAccount?>? attemptLightweightAuthentication({
    bool reportAllExceptions = false,
  }) => null;

  @override
  Future<void> disconnect() async {}

  @override
  Future<void> initialize({
    String? clientId,
    String? serverClientId,
    String? nonce,
    String? hostedDomain,
  }) async {}

  @override
  bool supportsAuthenticate() => true;

  @override
  bool authorizationRequiresUserInteraction() => false;

  @override
  Stream<GoogleSignInAuthenticationEvent> get authenticationEvents =>
      const Stream.empty();

  @override
  GoogleSignInAuthorizationClient get authorizationClient =>
      MockGoogleSignInAuthorizationClient();

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
    test('should return GoogleAuthResult with email, displayName, accessToken '
        'on success', () async {
      mockGoogleSignIn.accountToReturn = MockGoogleSignInAccount(
        email: 'ajit@example.com',
        displayName: 'Ajit',
        photoUrl: 'https://photo.url/avatar.png',
        accessToken: 'real-token',
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
