import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth_starter/features/profile/domain/repos/profile_repository.dart';
import 'package:firebase_auth_starter/features/profile/presentation/cubits/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository profileRepository;

  ProfileCubit({required this.profileRepository})
    : super(const ProfileInitial());

  Future<void> fetchUserProfile({required String targetUid}) async {
    try {
      emit(const ProfileLoading());

      final user = await profileRepository.fetchUserProfile(targetUid);

      if (user == null) {
        emit(const ProfileError(message: "User not found"));
        return;
      }

      emit(ProfileLoaded(profileUser: user));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }
}
