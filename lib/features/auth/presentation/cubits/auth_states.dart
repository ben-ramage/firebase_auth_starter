import 'package:firebase_auth_starter/features/auth/domain/entities/app_user.dart';
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class CheckingAuthState extends AuthState {
  const CheckingAuthState();

  @override
  List<Object?> get props => [];
}

class AuthLoading extends AuthState {
  const AuthLoading();

  @override
  List<Object?> get props => [];
}

class EmailVerificationPending extends AuthState {
  final String email;
  const EmailVerificationPending({required this.email});

  @override
  List<Object?> get props => [email];

  @override
  String toString() => 'Auth State: EmailVerificationPending(email: $email)';
}

class EmailVerificationAppliedSignedOut extends AuthState {
  const EmailVerificationAppliedSignedOut();

  @override
  List<Object?> get props => [];
}

class PasswordResetEmailSent extends AuthState {
  const PasswordResetEmailSent();

  @override
  List<Object?> get props => [];
}

class PasswordResetSuccess extends AuthState {
  const PasswordResetSuccess();

  @override
  List<Object?> get props => [];
}

class Authenticated extends AuthState {
  final AppUser user;
  const Authenticated({required this.user});

  @override
  List<Object?> get props => [user];

  @override
  String toString() => 'Auth State: Authenticated(user: ${user.email})';
}

class Unauthenticated extends AuthState {
  const Unauthenticated();

  @override
  List<Object?> get props => [];
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'Auth State: AuthError(message: $message)';
}

class AuthSettingsError extends AuthState {
  final String message;

  const AuthSettingsError({required this.message});

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'Auth State: AuthSettingsError(message: $message)';
}
