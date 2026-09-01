import 'package:firebase_auth_starter/features/profile/domain/entities/profile_user.dart';

abstract class ProfileRepository {
  Future<ProfileUser?> fetchUserProfile(String uid);
  Future<void> updateProfile(ProfileUser updatedProfile);
  Future<void> removeProfileImage(String uid);
  Future<void> deleteProfileImageByPath({
    required String uid,
    required String? storagePath,
  });
}
