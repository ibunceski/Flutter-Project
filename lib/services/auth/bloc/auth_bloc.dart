import 'package:bloc/bloc.dart';
import 'package:notesapp/services/auth/auth_provider.dart';
import 'package:notesapp/services/auth/bloc/auth_event.dart';
import 'package:notesapp/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateUninitialized(isLoading: true)) {
    on<AuthEventSendEmailVerification>(
      (event, emit) async {
        try {
          provider.sendEmailVerification();
          emit(state);
        } on Exception catch (e) {
          emit(AuthStateLoggedOut(exception: e, isLoading: false));
        }
      },
    );

    on<AuthEventRegister>((event, emit) async {
      final email = event.email;
      final password = event.password;
      try {
        await provider.createUser(email: email, password: password);
        await provider.sendEmailVerification();
        emit(const AuthStateNeedsVerifiction(isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateRegistering(
          exception: e,
          isLoading: false,
        ));
      }
    });

    on<AuthEventInitialize>(
      (event, emit) async {
        await provider.initialize();
        final user = provider.currentUser;
        if (user == null) {
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
        } else if (!user.isEmailVerified) {
          emit(const AuthStateNeedsVerifiction(isLoading: false));
        } else {
          emit(AuthStateLoggedIn(user: user, isLoading: false));
        }
      },
    );
    on<AuthEventLogIn>(
      (event, emit) async {
        emit(const AuthStateLoggedOut(
          exception: null,
          isLoading: true,
          loadingText: "Please wait while we log you in",
        ));
        final email = event.email;
        final password = event.password;
        try {
          final user = await provider.logIn(email: email, password: password);
          if (user.isEmailVerified) {
            emit(const AuthStateLoggedOut(exception: null, isLoading: false));
            emit(AuthStateLoggedIn(user: user, isLoading: false));
          } else {
            emit(const AuthStateLoggedOut(exception: null, isLoading: false));
            emit(const AuthStateNeedsVerifiction(isLoading: false));
          }
        } on Exception catch (e) {
          emit(AuthStateLoggedOut(
            exception: e,
            isLoading: false,
          ));
        }
      },
    );
    on<AuthEventLogOut>(
      (event, emit) async {
        try {
          await provider.logOut();
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
        } on Exception catch (e) {
          emit(AuthStateLoggedOut(exception: e, isLoading: false));
        }
      },
    );
  }
}
