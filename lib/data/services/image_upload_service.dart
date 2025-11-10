import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

class ImageUploadService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Upload multiple images to Firebase Storage and return download URLs
  static Future<List<String>> uploadPetImages({
    required String petId,
    required List<File> imageFiles,
    Function(double)? onProgress,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      if (imageFiles.isEmpty) {
        return [];
      }

      final List<String> downloadUrls = [];
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Upload each image
      for (int i = 0; i < imageFiles.length; i++) {
        final file = imageFiles[i];
        final fileName = '${timestamp}_$i${path.extension(file.path)}';
        final storageRef = _storage.ref().child(
              'pets/${currentUser.uid}/$petId/$fileName',
            );

        // Upload file with progress tracking
        final uploadTask = storageRef.putFile(file);

        // Listen to upload progress
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          if (onProgress != null) {
            final progress =
                (i + (snapshot.bytesTransferred / snapshot.totalBytes)) /
                    imageFiles.length;
            onProgress(progress);
          }
        });

        // Wait for upload to complete
        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);

        debugPrint(
            'Uploaded image ${i + 1}/${imageFiles.length}: $downloadUrl');
      }

      return downloadUrls;
    } catch (e) {
      debugPrint('Error uploading images: $e');
      rethrow;
    }
  }

  /// Update pet document with new photo URLs
  static Future<void> updatePetPhotos({
    required String petId,
    required List<dynamic> photoUrls,
  }) async {
    try {
      await _firestore.collection('pets').doc(petId).update({
        'photoUrls': photoUrls,
        'images': photoUrls, // Keep for backward compatibility
        'updatedAt': Timestamp.now(),
      });
      debugPrint('Updated pet photos in Firestore: ${photoUrls.length} URLs');
    } catch (e) {
      debugPrint('Error updating pet photos: $e');
      rethrow;
    }
  }

  /// Upload images and update pet document in one operation
  static Future<List<dynamic>> uploadAndUpdatePetPhotos({
    required String petId,
    required List<File> imageFiles,
    List<String>? existingUrls,
    Function(double)? onProgress,
  }) async {
    try {
      // Upload new images
      final newUrls = await uploadPetImages(
        petId: petId,
        imageFiles: imageFiles,
        onProgress: onProgress,
      );

      // Combine with existing URLs
      final allUrls = [
        ...(existingUrls ?? []),
        ...newUrls,
      ];

      // Update Firestore
      await updatePetPhotos(
        petId: petId,
        photoUrls: allUrls,
      );

      return allUrls;
    } catch (e) {
      debugPrint('Error in upload and update operation: $e');
      rethrow;
    }
  }

  /// Delete specific images from Firebase Storage
  static Future<void> deletePetImages({
    required List<String> imageUrls,
  }) async {
    try {
      for (final url in imageUrls) {
        try {
          final ref = _storage.refFromURL(url);
          await ref.delete();
          debugPrint('Deleted image: $url');
        } catch (e) {
          debugPrint('Error deleting image $url: $e');
          // Continue with other deletions even if one fails
        }
      }
    } catch (e) {
      debugPrint('Error deleting images: $e');
      rethrow;
    }
  }

  /// Delete all images for a pet
  static Future<void> deleteAllPetImages({
    required String petId,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final folderRef = _storage.ref().child('pets/${currentUser.uid}/$petId');
      final listResult = await folderRef.listAll();

      for (final item in listResult.items) {
        try {
          await item.delete();
          debugPrint('Deleted: ${item.fullPath}');
        } catch (e) {
          debugPrint('Error deleting ${item.fullPath}: $e');
        }
      }
    } catch (e) {
      debugPrint('Error deleting all pet images: $e');
      rethrow;
    }
  }

  /// Get storage usage for a pet (in bytes)
  static Future<int> getPetStorageUsage({
    required String petId,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return 0;
      }

      final folderRef = _storage.ref().child('pets/${currentUser.uid}/$petId');
      final listResult = await folderRef.listAll();

      int totalSize = 0;
      for (final item in listResult.items) {
        try {
          final metadata = await item.getMetadata();
          totalSize += metadata.size ?? 0;
        } catch (e) {
          debugPrint('Error getting metadata for ${item.fullPath}: $e');
        }
      }

      return totalSize;
    } catch (e) {
      debugPrint('Error getting storage usage: $e');
      return 0;
    }
  }

  /// Format bytes to human readable string
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  /// Check if URL is a Firebase Storage URL
  static bool isFirebaseStorageUrl(String url) {
    return url.contains('firebasestorage.googleapis.com') ||
        url.contains('storage.googleapis.com');
  }

  /// Extract file name from Firebase Storage URL
  static String getFileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        final encodedName = pathSegments.last.split('?').first;
        return Uri.decodeComponent(encodedName);
      }
      return 'unknown';
    } catch (e) {
      return 'unknown';
    }
  }
}
