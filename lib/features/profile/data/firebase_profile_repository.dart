import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_starter/features/profile/domain/entities/profile_user.dart';
import 'package:firebase_auth_starter/features/profile/domain/repos/profile_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class FirebaseProfileRepository extends ProfileRepository {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  final _cache = <String, ProfileUser>{};

  void invalidate(String uid) => _cache.remove(uid);

  DocumentReference<Map<String, dynamic>> _userRef(String uid) =>
      firebaseFirestore.collection('users').doc(uid);

  @override
  Future<ProfileUser?> fetchUserProfile(String uid) async {
    final cached = _cache[uid];
    if (cached != null) return cached;

    final userDoc = await _userRef(uid).get();
    if (!userDoc.exists) return cached;

    final user = ProfileUser.fromJson(userDoc.data()!);
    _cache[uid] = user;
    return user;
  }

  @override
  Future<void> updateProfile(ProfileUser user) async {
    final userDocRef = _userRef(user.uid);
    await userDocRef.set(user.toJson(), SetOptions(merge: true));
    invalidate(user.uid);
  }

  @override
  Future<void> removeProfileImage(String uid) async {
    final userDoc = await _userRef(uid).get();

    if (!userDoc.exists) return;

    final data = userDoc.data();
    final storagePath = data?['profileImageStoragePath'] as String?;

    await deleteProfileImageByPath(uid: uid, storagePath: storagePath);

    await _userRef(uid).set({
      'profileImageUrl': '',
      'profileImageStoragePath': null,
    }, SetOptions(merge: true));

    invalidate(uid);
  }

  bool _isSafeProfileImagePath({
    required String? storagePath,
    required String uid,
  }) {
    if (storagePath == null || storagePath.trim().isEmpty) {
      return false;
    }

    final trimmedPath = storagePath.trim();
    final expectedPrefix = 'profile_images/$uid/';

    return trimmedPath.startsWith(expectedPrefix) &&
        !trimmedPath.contains('..');
  }

  @override
  Future<void> deleteProfileImageByPath({
    required String uid,
    required String? storagePath,
  }) async {
    if (!_isSafeProfileImagePath(storagePath: storagePath, uid: uid)) {
      if (storagePath != null && storagePath.trim().isNotEmpty) {
        debugPrint('Unsafe profile image path detected, skipping delete.');
      }
      return;
    }

    try {
      await firebaseStorage.ref(storagePath!.trim()).delete();
    } on FirebaseException catch (e) {
      debugPrint('Storage delete failed for profile image: ${e.code}');
    }
  }
}
