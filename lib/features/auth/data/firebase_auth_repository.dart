import 'package:firebase_auth_starter/features/auth/domain/entities/app_user.dart';
import 'package:firebase_auth_starter/features/auth/domain/exceptions/auth_failure.dart';
import 'package:firebase_auth_starter/features/auth/domain/repos/auth_repository.dart';
// import 'package:mom/features/auth/domain/exceptions/auth_failure.dart';
// import 'package:mom/features/auth/domain/repos/auth_repository.dart';
// import 'package:mom/features/auth/domain/entities/app_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    try {
      final trimmedEmail = email.trim();

      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(
            email: trimmedEmail,
            password: password.trim(),
          );

      DocumentSnapshot userDoc = await firebaseFirestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists || userDoc.data() == null) {
        await firebaseAuth.signOut();

        throw const AuthFailure(
          'Your account exists, but setup was not completed. Please contact support.',
        );
      }

      final data = userDoc.data() as Map<String, dynamic>;

      return AppUser(
        uid: userCredential.user!.uid,
        name: data['name'] as String? ?? '',
        email: data['email'] as String? ?? '',
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          throw const AuthFailure("Incorrect email or password");
        case 'invalid-email':
          throw const AuthFailure("Invalid email format");
        default:
          throw AuthFailure(e.message ?? "Login failed.");
      }
    }
  }

  @override
  Future<AppUser?> registerWithEmailPassword(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) async {
    UserCredential? userCredential;

    try {
      final trimmedName = name.trim();
      final trimmedEmail = email.trim();

      userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: trimmedEmail,
        password: password.trim(),
      );

      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw const AuthFailure("Registration failed. Please try again.");
      }

      final user = AppUser(
        uid: firebaseUser.uid,
        name: trimmedName,
        email: trimmedEmail,
      );

      final userDocRef = firebaseFirestore.collection('users').doc(user.uid);

      await firebaseFirestore.runTransaction((transaction) async {
        transaction.set(userDocRef, user.toJson());
      });

      return user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw const AuthFailure("This email is alreasy in use.");
        case 'invalid-email':
          throw const AuthFailure("Invalid email format.");
        case 'weak-password':
          throw const AuthFailure("Password is too weak");
        default:
          throw AuthFailure(e.message ?? "Registration failed.");
      }
    } on AuthFailure {
      await _deleteIncompleteRegistrationUser(userCredential?.user);
      rethrow;
    } on FirebaseException catch (e) {
      await _deleteIncompleteRegistrationUser(userCredential?.user);
      throw AuthFailure(e.message ?? "Registration failed. Please try again.");
    } catch (_) {
      await _deleteIncompleteRegistrationUser(userCredential?.user);
      throw AuthFailure("Registration failed. Please try again.");
    }
  }

  @override
  Future<void> logout() async {
    firebaseAuth.signOut();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    final doc = await firebaseFirestore
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    if (!doc.exists || doc.data() == null) {
      await firebaseAuth.signOut();

      throw const AuthFailure(
        'Your account exists, but was not completed. Please contact support.',
      );
    }

    final data = doc.data() as Map<String, dynamic>;

    return AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? (data['email'] as String? ?? ''),
      name: data['name'] as String? ?? '',
    );
  }

  @override
  Future<AppUser?> reloadAndGetCurrentUser() async {
    final user = firebaseAuth.currentUser;

    if (user == null) return null;

    await user.reload();
    return getCurrentUser();
  }

  @override
  Future<bool> isCurrentUserEmailVerified() async {
    final user = firebaseAuth.currentUser;

    if (user == null) return false;

    await user.reload();
    return firebaseAuth.currentUser?.emailVerified ?? false;
  }

  @override
  Future<String?> getCurrentAuthEmail() async {
    final user = firebaseAuth.currentUser;

    if (user == null) return null;

    await user.reload();
    return firebaseAuth.currentUser?.email;
  }

  @override
  Future<void> syncFirestoreEmailFromAuth() async {
    try {
      final user = firebaseAuth.currentUser;

      if (user == null) {
        throw const AuthFailure("No authenticated user found.");
      }

      await user.reload();
      final refreshedUser = firebaseAuth.currentUser;

      if (refreshedUser == null || refreshedUser.email == null) {
        throw const AuthFailure("Unable to load updated email.");
      }

      final verifiedEmail = refreshedUser.email!.trim().toLowerCase();

      await firebaseFirestore.collection('users').doc(refreshedUser.uid).update(
        {'email': verifiedEmail},
      );
    } on FirebaseException catch (e) {
      throw AuthFailure(e.message ?? "Failure to update Firestore email.");
    }
  }

  @override
  Future<void> sendCurrentUserVerificationEmail() async {
    try {
      final user = firebaseAuth.currentUser;

      if (user == null) {
        throw const AuthFailure("No authenticated user found.");
      }

      await user.reload();

      if (!user.emailVerified) {
        await user.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Failed to send verification email.');
    }
  }

  @override
  Future<void> applyEmailVerificationCode(String actionCode) async {
    try {
      await firebaseAuth.applyActionCode(actionCode);
      await firebaseAuth.currentUser?.reload();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'expired-action-code':
          throw const AuthFailure("Verification link has expired.");
        case 'invalid-action-code':
          throw const AuthFailure("Invalid verification link.");
        default:
          throw AuthFailure(e.message ?? "Unable to verify email.");
      }
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(
        email: email.trim(),
        actionCodeSettings: ActionCodeSettings(
          url: 'https://firebaseauthstarter.web.app/__/auth/action',
          handleCodeInApp: true,
          androidPackageName: 'com.example.firebaseauthstarter',
          androidInstallApp: true,
          androidMinimumVersion: '21',
        ),
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw const AuthFailure("No account found for this email.");
        case 'invalid-email':
          throw const AuthFailure("Invalid email address.");
        default:
          throw AuthFailure(e.message ?? "Failed to send reset email.");
      }
    }
  }

  @override
  Future<String?> verifyPasswordResetCode(String actionCode) async {
    try {
      final ActionCodeInfo info = await firebaseAuth.checkActionCode(
        actionCode,
      );

      return info.data['email'] as String?;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'expired-action-code':
          throw const AuthFailure("Reset link has expired.");
        case 'invalid-action-code':
          throw const AuthFailure("Invalid reset link.");
        default:
          throw AuthFailure(e.message ?? "Invalid reset code.");
      }
    }
  }

  @override
  Future<void> confirmPasswordReset(
    String actionCode,
    String newPassword,
  ) async {
    try {
      await firebaseAuth.confirmPasswordReset(
        code: actionCode,
        newPassword: newPassword.trim(),
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'expired-action-code':
          throw const AuthFailure("Reset link has expired.");
        case 'invalid-action-code':
          throw const AuthFailure("Invalid reset link.");
        case 'weak-password':
          throw const AuthFailure("Password is too weak.");
        default:
          throw AuthFailure(e.message ?? "Password reset failed.");
      }
    }
  }

  @override
  Future<void> reauthenticateWithPassword({
    required String currentPassword,
  }) async {
    try {
      final user = firebaseAuth.currentUser;

      if (user == null || user.email == null) {
        throw const AuthFailure("No authenticated user found.");
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          throw const AuthFailure("Current password is incorrect.");
        case 'requires-recent-login':
          throw const AuthFailure(
            "Please login in again and retry this change.",
          );
        default:
          throw AuthFailure(e.message ?? "Reauthentication failed.");
      }
    }
  }

  // @override
  // Future<void> requestEmailChange({required String newEmail}) {
  //   // TODO: implement requestEmailChange
  //   throw UnimplementedError();
  // }

  // @override
  // Future<void> changePassword({
  //   required String currentPassword,
  //   required String newPassword,
  // }) {
  //   // TODO: implement changePassword
  //   throw UnimplementedError();
  // }

  Future<void> _deleteIncompleteRegistrationUser(User? user) async {
    if (user == null) return;

    try {
      await user.delete();
    } catch (_) {
      await firebaseAuth.signOut();
    }
  }
}
