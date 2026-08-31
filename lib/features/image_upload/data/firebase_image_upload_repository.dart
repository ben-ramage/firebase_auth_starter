import 'dart:typed_data';

import 'package:firebase_auth_starter/features/image_upload/domain/entities/upload_image.dart';
import 'package:firebase_auth_starter/features/image_upload/domain/repos/image_upload_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class FirebaseImageUploadRepository extends ImageUploadRepository {
  final FirebaseStorage storage;

  FirebaseImageUploadRepository({FirebaseStorage? storageInstance})
    : storage = storageInstance ?? FirebaseStorage.instance;

  @override
  Future<UploadImage> uploadProfileImageMobile(
    String path,
    String userId,
  ) async {
    final file = XFile(path);
    final fileBytes = await file.readAsBytes();

    return _uploadProfileImage(fileBytes, userId);
  }

  @override
  Future<UploadImage> uploadProfileImageWeb(
    Uint8List fileBytes,
    String userId,
  ) {
    return _uploadProfileImage(fileBytes, userId);
  }

  @override
  Future<void> deleteProfileImage(String storagePath) async {
    if (storagePath.trim().isEmpty) {
      return;
    }

    await storage.ref(storagePath).delete();
  }

  Future<UploadImage> _uploadProfileImage(
    Uint8List fileBytes,
    String userId,
  ) async {
    if (fileBytes.isEmpty) {
      throw Exception('Profile image is empty.');
    }

    final compressedBytes = await _compressImage(fileBytes);

    if (compressedBytes.isEmpty) {
      throw Exception('Profile image compression failed.');
    }

    final fileName = '${DateTime.now().microsecondsSinceEpoch}.webp';

    final storageRef = storage
        .ref()
        .child('profile_images')
        .child(userId)
        .child(fileName);

    final snapshot = await storageRef.putData(
      compressedBytes,
      SettableMetadata(contentType: 'image/webp'),
    );

    final downloadUrl = await snapshot.ref.getDownloadURL();

    return UploadImage(
      downloadUrl: downloadUrl,
      storagePath: snapshot.ref.fullPath,
    );
  }

  Future<Uint8List> _compressImage(Uint8List fileBytes) async {
    return FlutterImageCompress.compressWithList(
      fileBytes,
      format: CompressFormat.webp,
      quality: 70,
      minWidth: 800,
      minHeight: 800,
    );
  }
}
