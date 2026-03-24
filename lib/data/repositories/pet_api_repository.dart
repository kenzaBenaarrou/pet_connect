import 'dart:developer';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/pet_profile.dart';

/// Provider for PetApiRepository
final petApiRepositoryProvider = Provider<PetApiRepository>((ref) {
  return PetApiRepository();
});

/// Repository for Pet endpoints on NestJS backend
class PetApiRepository {
  final ApiService _apiService;

  PetApiRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Create a new pet with photos
  /// Converts pet images from local file paths to File objects for upload
  Future<PetProfile> createPet(PetProfile pet) async {
    // Check if there are local file paths that need to be uploaded
    final localImages = pet.images;
    // .where((path) => !path.startsWith('http://') && !path.startsWith('https://'))
    // .toList();

    if (localImages != null && localImages.isNotEmpty) {
      // Upload with multipart form data
      final files = localImages.map((path) => File(path)).toList();

      final fields = <String, String>{
        'name': pet.name ?? '',
        'age': pet.age.toString(),
        'breed': pet.breed ?? "",
        'size': pet.size ?? "",
        'temperament': pet.temperament!.join(','),
        'vaccinated': pet.vaccinated.toString(),
        'fixed': pet.fixed.toString(),
        if (pet.bio != null) 'bio': pet.bio!,
        if (pet.geoPoint != null) 'latitude': pet.geoPoint!.latitude.toString(),
        if (pet.geoPoint != null)
          'longitude': pet.geoPoint!.longitude.toString(),
      };

      final response = await _apiService.uploadMultipartForm(
        '/pets',
        method: 'POST',
        files: files,
        filesFieldName: 'images',
        fields: fields,
      );
      return PetProfile.fromJson(response);
    } else {
      var petJson = pet.toJson();
      petJson.removeWhere((key, value) => key == 'id' || value == null);
      log('pets: $petJson');
      // No local files, send as JSON
      final response = await _apiService.post(
        '/pets',
        body: petJson,
      );
      return PetProfile.fromJson(response);
    }
  }

  /// Get pet by ID
  Future<PetProfile> getPet(int petId) async {
    final response = await _apiService.get('/pets/$petId');
    return PetProfile.fromJson(response);
  }

  /// Get all pets for an owner
  Future<List<PetProfile>> getPetsByOwner(int ownerId) async {
    final response = await _apiService.get('/pets/owner/$ownerId');
    return (response as List).map((json) => PetProfile.fromJson(json)).toList();
  }

  /// Update pet profile with photos
  /// Converts pet images from local file paths to File objects for upload
  Future<PetProfile> updatePet(PetProfile pet) async {
    // Check if there are local file paths that need to be uploaded
    final localImages = pet.images!
        .where((path) =>
            !path.startsWith('http://') && !path.startsWith('https://'))
        .toList();

    if (localImages.isNotEmpty) {
      // Upload with multipart form data
      final files = localImages.map((path) => File(path)).toList();

      // Include existing URLs as a field
      final existingUrls = pet.images!
          .where((path) =>
              path.startsWith('http://') || path.startsWith('https://'))
          .join(',');

      final fields = <String, String>{
        'name': pet.name ?? "",
        'age': pet.age.toString(),
        'breed': pet.breed ?? "",
        'size': pet.size ?? "",
        'temperament': pet.temperament!.join(','),
        'vaccinated': pet.vaccinated.toString(),
        'fixed': pet.fixed.toString(),
        if (pet.bio != null) 'bio': pet.bio!,
        // if (pet.geoPoint != null) 'latitude': pet.geoPoint!.latitude.toString(),
        // if (pet.geoPoint != null)
        //   'longitude': pet.geoPoint!.longitude.toString(),

        if (existingUrls.isNotEmpty) 'existingImages': existingUrls,
      };
      log("fields:$fields");
      final response = await _apiService.uploadMultipartForm(
        '/pets/${pet.id}',
        method: 'PATCH',
        files: files,
        filesFieldName: 'images',
        fields: fields,
      );

      log("response:$response");
      return PetProfile.fromJson(response);
    } else {
      // No local files, send as JSON
      var petJson = pet.toJson();
      petJson.removeWhere((key, value) =>
          key == 'ownerId' ||
          key == 'id' ||
          key == 'createdAt' ||
          key == 'updatedAt' ||
          value == null);
      final response = await _apiService.patch(
        '/pets/${pet.id}',
        body: petJson,
      );
      return PetProfile.fromJson(response);
    }
  }

  /// Delete pet
  Future<void> deletePet(String petId) async {
    await _apiService.delete('/pets/$petId');
  }

  /// Get pets for discovery (swipe screen)
  Future<List<PetProfile>> getDiscoveryPets({
    int limit = 10,
    int? minAge,
    int? maxAge,
    List<String>? sizes,
    int? distance,
    int? lastPetId,
  }) async {
    // final queryParams = <String, dynamic>{
    //   'limit': limit,
    //   if (minAge != null) 'minAge': minAge,
    //   if (maxAge != null) 'maxAge': maxAge,
    //   if (sizes != null && sizes.isNotEmpty) 'sizes': sizes.join(','),
    //   if (distance != null) 'distance': distance,
    //   if (lastPetId != null) 'lastPetId': lastPetId,
    // };

    // final query = queryParams.entries
    //     .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
    //     .join('&');

    // final response = await _apiService.get('/pets/discovery?$query');
    final response = await _apiService.get('/pets');
    return (response as List).map((json) => PetProfile.fromJson(json)).toList();
  }

  /// Search pets
  // Future<List<PetProfile>> searchPets({
  //   String? breed,
  //   String? size,
  //   int? minAge,
  //   int? maxAge,
  // }) async {
  //   final queryParams = <String, dynamic>{};
  //   if (breed != null) queryParams['breed'] = breed;
  //   if (size != null) queryParams['size'] = size;
  //   if (minAge != null) queryParams['minAge'] = minAge;
  //   if (maxAge != null) queryParams['maxAge'] = maxAge;

  //   final query = queryParams.entries
  //       .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
  //       .join('&');

  //   final response = await _apiService.get('/pets/search?$query');
  //   return (response as List).map((json) => PetProfile.fromJson(json)).toList();
  // }
}
