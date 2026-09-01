import 'package:firebase_auth_starter/features/auth/domain/entities/app_user.dart';

class ProfileUser extends AppUser {
  final String bio;
  final String profileImageUrl;
  final String? profileImageStoragePath;

  ProfileUser({
    required super.uid,
    required super.name,
    required super.email,
    required this.bio,
    required this.profileImageUrl,
    this.profileImageStoragePath,
  });

  ProfileUser copyWith({
    String? newBio,
    String? newName,
    String? newProfileImageUrl,
    String? newProfileImageStoragePath,
  }) {
    return ProfileUser(
      uid: uid,
      name: newName ?? name,
      email: email,
      bio: newBio ?? bio,
      profileImageUrl: newProfileImageUrl ?? profileImageUrl,
      profileImageStoragePath:
          newProfileImageStoragePath ?? profileImageStoragePath,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'profileImageStoragePath': profileImageStoragePath,
    };
  }

  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    return ProfileUser(
      uid: json['uid'] as String,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      profileImageUrl: json['profileImageUrl'] as String? ?? '',
      profileImageStoragePath: json['profileImageStoragePath'] as String?,
    );
  }
}
