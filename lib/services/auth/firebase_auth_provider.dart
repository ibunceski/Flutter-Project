import 'package:firebase_core/firebase_core.dart';
import 'package:notesapp/firebase_options.dart';
import 'package:notesapp/services/auth/auth_exceptions.dart';
import 'package:notesapp/services/auth/auth_user.dart';
import 'package:notesapp/services/auth/auth_provider.dart';

import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException;



class FirebaseAuthProvider implements AuthProvider {

  @override
  Future<void> initialize() async{
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
    ) ;
  }

  @override
  Future<AuthUser> createUser(
      {required String email, required String password}) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (exception) {
      if (exception.code == "invalid-email") {
        throw InvalidEmailAuthException();
      } else if (exception.code == "email-already-in-use") {
        throw EmailAlreadyInUseAuthException();
      } else if (exception.code == "weak-password") {
        throw WeakPasswordAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (e) {
      throw GenericAuthException();
    }
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (exception) {
        if (exception.code == "invalid-credential") {
          throw InvalidCredentialsAuthException();
        }else{
          throw GenericAuthException();
        }
    } catch (exception) {
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logOut() async{
      final user = FirebaseAuth.instance.currentUser;
      if(user != null){
        await FirebaseAuth.instance.signOut();
      }else{
        throw UserNotLoggedInAuthException();
      }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }
}
