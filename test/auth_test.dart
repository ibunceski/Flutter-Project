import 'package:notesapp/services/auth/auth_exceptions.dart';
import 'package:notesapp/services/auth/auth_provider.dart';
import 'package:notesapp/services/auth/auth_user.dart';
import 'package:notesapp/services/auth/bloc/auth_state.dart';
import 'package:test/test.dart';

void main() {
  group("Mock Authentication", () {
    final provider = MockAuthProvider();
    test("Should not be initialized to begin with", () {
      expect(provider.isInitialized, false);
    });

    test("Cannot log out if not initialized", () {
      expect(
        provider.logOut(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });

    test("Should be able to be initialzied", () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test("User should be null after initialization", () {
      expect(provider.currentUser, null);
    });

    test("Should be able to initialize in less than 2 seconds", () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    }, timeout: const Timeout(Duration(seconds: 2)));

    test("Create user should delegate to logIn function", () async {
      try {
        await provider.createUser(email: "foo@bar.com", password: "foobar");
      } catch (e) {
        expect(e, isA<InvalidCredentialsAuthException>());
      }

      try {
        await provider.createUser(email: "fo@bar.com", password: "foobar");
      } catch (e) {
        expect(e, isA<InvalidCredentialsAuthException>());
      }

      final user = await provider.createUser(email: "foo", password: "bar");
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });

    test("Logged in user should be able to get verified", () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user?.isEmailVerified, true);
    });

    test("Should be able to log out and log in again", () async {
      await provider.logOut();
      await provider.logIn(email: "user", password: "password");
      final user = provider.currentUser;
      expect(user, isNotNull);
    });

    test("Should throw exception if not initialized", () async {
      try {
        await provider.sendPasswordReset(toEmail: "ibunc@gm.com");
      } catch (e) {
        expect(e, isA<NotInitializedException>());
      }
    });

    test("Should throw UserNotFoundAuthException for unregistered email",
        () async {
      await provider.initialize();
      expect(
        provider.sendPasswordReset(toEmail: "unknown@gm.com"),
        throwsA(isA<UserNotFoundAuthException>()),
      );
    });

    test("Should send password reset for registered email", () async {
      await provider.initialize();
      await provider.sendPasswordReset(toEmail: "ibunc@gm.com");
      // No exception thrown, so we pass the test.
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser(
      {required String email, required String password}) async {
    if (!_isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    if (!_isInitialized) throw NotInitializedException();
    if (email == "foo@bar.com") throw InvalidCredentialsAuthException();
    if (password == "foobar") throw InvalidCredentialsAuthException();
    const user =
        AuthUser(id: "myid", isEmailVerified: false, email: 'ibunc@gm.com');
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!_isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotLoggedInAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotLoggedInAuthException();
    const newUser =
        AuthUser(id: "myid", isEmailVerified: true, email: 'ibunc@gm.com');
    _user = newUser;
  }

  @override
  Future<void> sendPasswordReset({required String toEmail}) async {
    if (!_isInitialized) throw NotInitializedException();
    if (toEmail != "ibunc@gm.com") throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
  }
}
