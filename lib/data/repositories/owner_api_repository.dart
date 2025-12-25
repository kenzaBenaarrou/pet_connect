import 'dart:developer';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_con/data/models/user_model.dart';
import '../services/api_service.dart';
import '../models/owner_profile.dart';
import '../services/secure_storage_service.dart';

/// Provider for OwnerApiRepository
final ownerApiRepositoryProvider = Provider<OwnerApiRepository>((ref) {
  return OwnerApiRepository();
});

/// Repository for Owner/User endpoints on NestJS backend
class OwnerApiRepository {
  final ApiService _apiService;

  OwnerApiRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Get current user profile
  Future<OwnerProfile> getCurrentProfile() async {
    final userId = await SecureStorageService.getUserId();
    final response = await _apiService.get('/users/$userId');
    return OwnerProfile.fromJson(response);
  }

  /// Get owner profile by ID
  Future<OwnerProfile> getOwnerProfile(String ownerId) async {
    final response = await _apiService.get('/users/$ownerId');
    return OwnerProfile.fromJson(response);
  }

  /// Create owner profile with photo
  Future<UserModel> createOwnerProfile(UserModel profile) async {
    // Check if there's a local file path that needs to be uploaded
    final hasLocalPhoto = profile.photo != null &&
        !profile.photo!.startsWith('http://') &&
        !profile.photo!.startsWith('https://');
    if (hasLocalPhoto) {
      // Upload with multipart form data
      final file = File(profile.photo!);

      final fields = <String, String>{
        'firstName': profile.firstname ?? '',
        'lastName': profile.lastname ?? '',
        if (profile.bio != null) 'bio': profile.bio!,
      };

      final response = await _apiService.uploadMultipartForm(
        '/users',
        method: 'POST',
        files: [file],
        filesFieldName: 'photo',
        fields: fields,
      );
      return UserModel.fromJson(response);
    } else {
      // No local file, send as JSON
      final response = await _apiService.post(
        '/users',
        body: profile.toJson(),
      );
      return UserModel.fromJson(response);
    }
  }

  /// Update owner profile with photo
  Future<UserModel> updateOwnerProfile(UserModel profile) async {
    // Check if there's a local file path that needs to be uploaded
    // log(' owner profile: ${profile.toJson()}');
    var userId = await SecureStorageService.getUserId();
    final hasLocalPhoto = profile.photo != null &&
        !profile.photo!.startsWith('http://') &&
        !profile.photo!.startsWith('https://');

    if (hasLocalPhoto) {
      // Upload with multipart form data
      final file = File(profile.photo!);
      final fields = <String, String>{
        'firstName': profile.firstname ?? '',
        'lastName': profile.lastname ?? '',
        'email': profile.email ?? '',
        if (profile.bio != null) 'bio': profile.bio!,
        // if (profile.pets != null && profile.pets!.isNotEmpty) 'pet': profile.pets!.map((pet) => pet.id).join(','),
      };

      final response = await _apiService.uploadMultipartForm(
        '/users/${profile.id}',
        method: 'PATCH',
        files: [file],
        filesFieldName: 'photo',
        fields: fields,
      );
      return UserModel.fromJson(response);
    } else {
      // No local file or no photo at all, send as JSON (includes case where photo is null)
      // Remove null values to only send fields that were actually set

      final jsonData = profile.toJson();
      jsonData.removeWhere((key, value) => value == null || key == 'id');
      // log('Updating owner profile without photo upload: ${jsonData}');
      final response = await _apiService.patch(
        '/users/$userId',
        body: jsonData,
      );
      return UserModel.fromJson(response);
    }
  }

  /// Delete owner profile
  Future<void> deleteOwnerProfile(String ownerId) async {
    await _apiService.delete('/users/$ownerId');
  }

  /// Search owners by criteria
  Future<List<OwnerProfile>> searchOwners({
    String? name,
    String? location,
    int? distance,
  }) async {
    final queryParams = <String, dynamic>{};
    if (name != null) queryParams['name'] = name;
    if (location != null) queryParams['location'] = location;
    if (distance != null) queryParams['distance'] = distance;

    final query = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');

    final response = await _apiService.get('/users/search?$query');
    return (response as List)
        .map((json) => OwnerProfile.fromJson(json))
        .toList();
  }
}
