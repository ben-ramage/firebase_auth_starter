import 'package:firebase_auth_starter/features/auth/domain/entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser?> loginWithEmailPassword(String email, String password);

  Future<AppUser?> registerWithEmailPassword(
    String name,
    String email,
    String password,
    String confirmPassword,
  );

  Future<void> logout();

  Future<AppUser?> getCurrentUser();

  Future<AppUser?> reloadAndGetCurrentUser();

  Future<bool> isCurrentUserEmailVerified();

  Future<String?> getCurrentAuthEmail();

  Future<void> syncFirestoreEmailFromAuth();

  Future<void> sendCurrentUserVerificationEmail();

  Future<void> applyEmailVerificationCode(String actionCode);

  Future<void> sendPasswordResetEmail(String email);

  Future<String?> verifyPasswordResetCode(String actionCode);

  Future<void> confirmPasswordReset(String actionCode, String newPassword);

  Future<void> reauthenticateWithPassword({required String currentPassword});

  // Future<void> requestEmailChange({required String newEmail});

  // Future<void> changePassword({
  //   required String currentPassword,
  //   required String newPassword,
  // });
}
