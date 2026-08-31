import 'dart:typed_data';
import 'package:firebase_auth_starter/features/image_upload/domain/entities/upload_image.dart';

abstract class ImageUploadRepository {
  Future<UploadImage> uploadProfileImageMobile(String path, String userId);

  Future<UploadImage> uploadProfileImageWeb(Uint8List fileBytes, String userId);

  Future<void> deleteProfileImage(String storagePath);
}
