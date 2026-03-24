
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pet_con/data/models/pet_profile.dart';
import 'package:pet_con/data/models/user_model.dart';
import 'package:pet_con/data/repositories/owner_api_repository.dart';
import 'package:pet_con/data/repositories/pet_api_repository.dart';
import 'package:pet_con/data/services/secure_storage_service.dart';

// Onboarding State
class OnboardingState {
  final bool isLoading;
  final String? error;

  // Owner data
  final String? ownerFirstname;
  final String? ownerLastName;

  final String? ownerBio;
  final String? ownerProfilePicture;
  final GeoPoint? ownerLocation;

  // Pet data
  final String? petName;
  final int? petAge;
  final String? petBreed;
  final String? petSize;
  final List<String> petTemperament;
  final bool petVaccinated;
  final bool petFixed;
  final String? petBio;
  final List<String> petImages;

  const OnboardingState({
    this.isLoading = false,
    this.error,
    this.ownerFirstname,
    this.ownerLastName,
    this.ownerBio,
    this.ownerProfilePicture,
    this.ownerLocation,
    this.petName,
    this.petAge,
    this.petBreed,
    this.petSize,
    this.petTemperament = const [],
    this.petVaccinated = false,
    this.petFixed = false,
    this.petBio,
    this.petImages = const [],
  });

  OnboardingState copyWith({
    bool? isLoading,
    String? error,
    String? ownerFirstname,
    String? ownerLastName,
    String? ownerBio,
    String? ownerProfilePicture,
    GeoPoint? ownerLocation,
    String? petName,
    int? petAge,
    String? petBreed,
    String? petSize,
    List<String>? petTemperament,
    bool? petVaccinated,
    bool? petFixed,
    String? petBio,
    List<String>? petImages,
  }) {
    return OnboardingState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      ownerFirstname: ownerFirstname ?? this.ownerFirstname,
      ownerLastName: ownerLastName ?? this.ownerLastName,
      ownerBio: ownerBio ?? this.ownerBio,
      ownerProfilePicture: ownerProfilePicture ?? this.ownerProfilePicture,
      ownerLocation: ownerLocation ?? this.ownerLocation,
      petName: petName ?? this.petName,
      petAge: petAge ?? this.petAge,
      petBreed: petBreed ?? this.petBreed,
      petSize: petSize ?? this.petSize,
      petTemperament: petTemperament ?? this.petTemperament,
      petVaccinated: petVaccinated ?? this.petVaccinated,
      petFixed: petFixed ?? this.petFixed,
      petBio: petBio ?? this.petBio,
      petImages: petImages ?? this.petImages,
    );
  }
}

// Onboarding Notifier
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final OwnerApiRepository _ownerApiRepository;
  final PetApiRepository _petApiRepository;

  OnboardingNotifier(this._ownerApiRepository, this._petApiRepository)
      : super(const OnboardingState());

  void setOwnerData({
    required String firstname,
    required String lastname,
    String? bio,
  }) {
    state = state.copyWith(
      ownerFirstname: firstname,
      ownerLastName: lastname,
      ownerBio: bio,
    );
  }

  void setOwnerProfilePicture(String imageUrl) {
    state = state.copyWith(ownerProfilePicture: imageUrl);
  }

  Future<void> requestLocationPermission() async {
    try {
      state = state.copyWith(isLoading: true);

      // Check and request location permission
      var permission = await Permission.location.status;
      if (permission.isDenied) {
        permission = await Permission.location.request();
      }

      if (permission.isGranted) {
        // Get current location
        final position = await Geolocator.getCurrentPosition();
        final geoPoint = GeoPoint(position.latitude, position.longitude);

        state = state.copyWith(
          ownerLocation: geoPoint,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Location permission is required to find nearby pets',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to get location: $e',
      );
    }
  }

  void setPetData({
    required String name,
    required int age,
    required String breed,
    required String size,
    required List<String> temperament,
    required bool vaccinated,
    required bool fixed,
    String? bio,
  }) {
    state = state.copyWith(
      petName: name,
      petAge: age,
      petBreed: breed,
      petSize: size,
      petTemperament: temperament,
      petVaccinated: vaccinated,
      petFixed: fixed,
      petBio: bio,
    );
  }

  void setPetImages(List<String> images) {
    state = state.copyWith(petImages: images);
  }

  Future<void> completeOnboarding() async {
    try {
      state = state.copyWith(isLoading: true);

      // Get user ID from secure storage
      final userId = await SecureStorageService.getUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Create/Update owner profile with onboarding data via NestJS API
      // During onboarding, the user already exists from registration
      // but we need to update with profile picture, bio, etc.
      // Only send non-null fields
      final ownerProfile = UserModel(
        id: userId,
        firstname: state.ownerFirstname,
        lastname: state.ownerLastName,
        photo: state.ownerProfilePicture,
        bio: state.ownerBio,
      );
      // log('Updating owner profile: ${ownerProfile.toJson()}');

      await _ownerApiRepository.updateOwnerProfile(ownerProfile);

      // Create pet profile via NestJS API
      final petProfile = PetProfile(
        // Will be auto-generated by backend
        ownerId: userId,
        name: state.petName!,
        age: state.petAge!,
        breed: state.petBreed!,
        size: state.petSize!,
        temperament: state.petTemperament,
        vaccinated: state.petVaccinated,
        fixed: state.petFixed,
        bio: state.petBio,
        images: state.petImages,
        geoPoint: state.ownerLocation,
      );

      await _petApiRepository.createPet(petProfile);

      // The backend should automatically associate the pet with the owner
      // No need for additional update call if your backend handles this

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to complete onboarding: $e',
      );
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  final ownerApiRepository = OwnerApiRepository();
  final petApiRepository = PetApiRepository();
  return OnboardingNotifier(ownerApiRepository, petApiRepository);
});
