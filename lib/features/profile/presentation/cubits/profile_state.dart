import 'package:equatable/equatable.dart';
import 'package:firebase_auth_starter/features/profile/domain/entities/profile_user.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

// Initial State
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

// Profile Loading State
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

// Profile Loaded State
class ProfileLoaded extends ProfileState {
  final ProfileUser profileUser;
  const ProfileLoaded({required this.profileUser});

  @override
  List<Object?> get props => [profileUser];
}

// Profile Error State
class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}
