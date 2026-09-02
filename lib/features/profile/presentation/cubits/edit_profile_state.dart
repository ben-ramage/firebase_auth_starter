import 'package:equatable/equatable.dart';

abstract class EditProfileState extends Equatable {
  const EditProfileState();

  @override
  List<Object?> get props => [];
}

// Initial State
class EditProfileInitial extends EditProfileState {
  const EditProfileInitial();
}

// Edit Profile Loading
class EditProfileLoading extends EditProfileState {
  const EditProfileLoading();
}

// Edit Profile Success
class EditProfileSuccess extends EditProfileState {
  const EditProfileSuccess();
}

// Edit Profile Image Removed
class EditProfileImageRemoved extends EditProfileState {
  const EditProfileImageRemoved();
}

// Edit Profile Error
class EditProfileError extends EditProfileState {
  final String message;

  const EditProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}
