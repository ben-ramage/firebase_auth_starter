import 'dart:typed_data';

import 'package:firebase_auth_starter/features/image_upload/domain/repos/image_upload_repository.dart';
import 'package:firebase_auth_starter/features/profile/domain/repos/profile_repository.dart';
import 'package:firebase_auth_starter/features/profile/presentation/cubits/edit_profile_state.dart';
import 'package:firebase_auth_starter/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  final ProfileRepository profileRepository;
  final ImageUploadRepository imageUploadRepository;
  final ProfileCubit profileCubit;

  EditProfileCubit({
    required this.profileRepository,
    required this.imageUploadRepository,
    required this.profileCubit,
  }) : super(const EditProfileInitial());

  Future<void> updateProfile({
    required String uid,
    String? newName,
    String? newBio,
    Uint8List? imageWebBytes,
    String? imageMobilePath,
  }) async {
    emit(const EditProfileLoading());

    try {
      final currentUser = await profileRepository.fetchUserProfile(uid);

      if (currentUser == null) {
        emit(
          const EditProfileError(
            message: "Failed to fetch user for profile update",
          ),
        );
        return;
      }

      String? imageDownloadUrl;
      String? imageStoragePath;
      final oldImageStoragePath = currentUser.profileImageStoragePath;

      if (imageWebBytes != null || imageMobilePath != null) {
        final uploadedImage = imageMobilePath != null
            ? await imageUploadRepository.uploadProfileImageMobile(
                imageMobilePath,
                uid,
              )
            : await imageUploadRepository.uploadProfileImageWeb(
                imageWebBytes!,
                uid,
              );

        imageDownloadUrl = uploadedImage.downloadUrl;
        imageStoragePath = uploadedImage.storagePath;
      }

      final updatedProfile = currentUser.copyWith(
        newName: newName ?? currentUser.name,
        newBio: newBio ?? currentUser.bio,
        newProfileImageUrl: imageDownloadUrl ?? currentUser.profileImageUrl,
        newProfileImageStoragePath:
            imageStoragePath ?? currentUser.profileImageStoragePath,
      );

      await profileRepository.updateProfile(updatedProfile);

      if (imageStoragePath != null && oldImageStoragePath != imageStoragePath) {
        await profileRepository.deleteProfileImageByPath(
          uid: uid,
          storagePath: oldImageStoragePath,
        );
      }

      await profileCubit.fetchUserProfile(targetUid: uid);

      emit(const EditProfileSuccess());
    } catch (e) {
      emit(EditProfileError(message: "Error updating profile: $e"));
    }
  }

  Future<void> removeProfilePicture({required String uid}) async {
    emit(const EditProfileLoading());

    try {
      await profileRepository.removeProfileImage(uid);

      await profileCubit.fetchUserProfile(targetUid: uid);

      emit(const EditProfileImageRemoved());
    } catch (e) {
      emit(EditProfileError(message: 'Error removing profile image: $e'));
    }
  }
}
