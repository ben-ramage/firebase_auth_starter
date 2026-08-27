import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_starter/features/auth/domain/entities/app_user.dart';
import 'package:firebase_auth_starter/features/auth/domain/repos/auth_repository.dart';
import 'package:firebase_auth_starter/features/auth/presentation/cubits/auth_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  Timer? _emailChecktimer;

  late final StreamSubscription<User?> _authSubscription;

  void _startEmailVerificationTimer() {
    _emailChecktimer?.cancel();
    _emailChecktimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      try {
        final isVerified = await authRepository.isCurrentUserEmailVerified();

        if (!isVerified) {
          return;
        }

        _emailChecktimer?.cancel();
        await _refreshAuthenticatedUser();
      } catch (e) {
        _emailChecktimer?.cancel();

        emit(
          const AuthError(
            message: "Unable to check verification. Please try again.",
          ),
        );

        final email = await _safeGetCurrentAuthEmail();
        emit(EmailVerificationPending(email: email ?? ''));
      }
    });
  }

  Future<String?> _safeGetCurrentAuthEmail() async {
    try {
      return authRepository.getCurrentAuthEmail();
    } catch (_) {
      return null;
    }
  }

  Future<void> _refreshAuthenticatedUser() async {
    try {
      final appUser = await authRepository.getCurrentUser();

      if (appUser != null) {
        _currentUser = appUser;
        emit(Authenticated(user: appUser));
        return;
      }

      _currentUser = null;
      emit(const Unauthenticated());
    } catch (e) {
      _currentUser = null;
      emit(AuthError(message: e.toString()));
      emit(const Unauthenticated());
    }
  }

  AuthCubit({required this.authRepository}) : super(const CheckingAuthState()) {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(
      (user) async {
        try {
          _emailChecktimer?.cancel();

          if (user == null) {
            _currentUser = null;
            emit(const Unauthenticated());
            return;
          }

          final isVerified = await authRepository.isCurrentUserEmailVerified();

          if (!isVerified) {
            _currentUser = null;
            final email = await authRepository.getCurrentAuthEmail();
            emit(EmailVerificationPending(email: email ?? ''));
            _startEmailVerificationTimer();
            return;
          }

          await _refreshAuthenticatedUser();
        } catch (e) {
          _currentUser = null;
          _emailChecktimer?.cancel();

          emit(AuthError(message: e.toString()));
          emit(const AuthLoading());
        }
      },
      onError: (Object error) {
        _currentUser = null;
        _emailChecktimer?.cancel();

        emit(AuthError(message: error.toString()));
        emit(const Unauthenticated());
      },
    );
  }

  Future<void> login(String email, String password) async {
    emit(const AuthLoading());

    try {
      final user = await authRepository.loginWithEmailPassword(email, password);

      if (user == null) {
        _currentUser = null;
        emit(const Unauthenticated());
        return;
      }

      final isVerified = await authRepository.isCurrentUserEmailVerified();

      if (!isVerified) {
        _currentUser = null;
        final authEmail =
            await authRepository.getCurrentAuthEmail() ?? email.trim();
        emit(EmailVerificationPending(email: authEmail));
        _startEmailVerificationTimer();
        return;
      }

      final refreshedUser = await authRepository.reloadAndGetCurrentUser();

      if (refreshedUser == null) {
        _currentUser = null;
        emit(const Unauthenticated());
        return;
      }

      await authRepository.syncFirestoreEmailFromAuth();

      final syncedUser = await authRepository.getCurrentUser();

      if (syncedUser == null) {
        _currentUser = null;
        emit(const Unauthenticated());
        return;
      }

      _currentUser = syncedUser;
      emit(Authenticated(user: syncedUser));
    } catch (e) {
      _currentUser == null;
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> register(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) async {
    emit(const AuthLoading());

    try {
      final user = await authRepository.registerWithEmailPassword(
        name,
        email,
        password,
        confirmPassword,
      );

      if (user == null) {
        _currentUser = null;
        emit(const Unauthenticated());
        return;
      }

      _currentUser = user;

      await authRepository.sendCurrentUserVerificationEmail();
      emit(EmailVerificationPending(email: email.trim()));
      _startEmailVerificationTimer();
    } catch (e) {
      _currentUser = null;
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> logout() async {
    _emailChecktimer?.cancel();
    await authRepository.logout();
    _currentUser = null;
    emit(const Unauthenticated());
  }

  Future<void> cancelEmailVerification() async {
    _emailChecktimer?.cancel();

    await authRepository.logout();

    _currentUser = null;
    emit(const Unauthenticated());
  }

  Future<bool> resendVerificationEmail() async {
    try {
      await authRepository.sendCurrentUserVerificationEmail();
      final email = await authRepository.getCurrentAuthEmail();
      emit(EmailVerificationPending(email: email ?? ''));
      return true;
    } catch (e) {
      emit(AuthError(message: e.toString()));
      return false;
    }
  }

  Future<void> applyEmailVerificationCode(String actionCode) async {
    emit(const AuthLoading());

    try {
      await authRepository.applyEmailVerificationCode(actionCode);

      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser == null) {
        _currentUser = null;
        _emailChecktimer?.cancel();
        emit(const EmailVerificationAppliedSignedOut());
        return;
      }

      await firebaseUser.reload();

      final isVerified = await authRepository.isCurrentUserEmailVerified();

      if (!isVerified) {
        final email = await authRepository.getCurrentAuthEmail();
        _currentUser = null;
        emit(EmailVerificationPending(email: email ?? ''));
        _startEmailVerificationTimer();
        return;
      }

      await authRepository.syncFirestoreEmailFromAuth();
      await _refreshAuthenticatedUser();
    } catch (e) {
      _currentUser = null;
      emit(AuthError(message: e.toString()));
    }
  }

  Future<bool> applyEmailChangeCode(String actionCode) async {
    emit(const AuthLoading());

    try {
      await authRepository.applyEmailVerificationCode(actionCode);
      await authRepository.logout();

      _currentUser = null;
      _emailChecktimer?.cancel();
      emit(const Unauthenticated());

      return true;
    } catch (e) {
      emit(AuthError(message: e.toString()));
      return false;
    }
  }

  Future<void> requestPasswordReset(String email) async {
    emit(const AuthLoading());
    try {
      await authRepository.sendPasswordResetEmail(email);
      emit(const PasswordResetEmailSent());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<String?> verifyPasswordResetCode(String actionCode) async {
    try {
      final email = await authRepository.verifyPasswordResetCode(actionCode);

      if (email == null) {
        emit(
          const AuthError(message: "Invalid or expired password reset link."),
        );
        return null;
      }

      return email;
    } catch (e) {
      emit(AuthError(message: e.toString()));
      return null;
    }
  }

  Future<void> completePasswordReset(
    String actionCode,
    String newPassword,
  ) async {
    emit(const AuthLoading());

    try {
      await authRepository.confirmPasswordReset(actionCode, newPassword);
      emit(const PasswordResetSuccess());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _emailChecktimer?.cancel();
    _authSubscription.cancel();
    return super.close();
  }
}
