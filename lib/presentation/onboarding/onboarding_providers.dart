import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pet_con/data/models/owner_profile.dart';
import 'package:pet_con/data/models/pet_profile.dart';
import 'package:pet_con/data/repositories/owner_repository.dart';
import 'package:pet_con/data/services/firebase_service.dart';

// Onboarding State
class OnboardingState {
  final bool isLoading;
  final String? error;

  // Owner data
  final String? ownerName;
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
    this.ownerName,
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
    String? ownerName,
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
      ownerName: ownerName ?? this.ownerName,
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
  final OwnerRepository _ownerRepository;
  final PetRepository _petRepository;

  OnboardingNotifier(this._ownerRepository, this._petRepository)
      : super(const OnboardingState());

  void setOwnerData({
    required String name,
    String? bio,
  }) {
    state = state.copyWith(
      ownerName: name,
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

      final userId = FirebaseService.currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final now = DateTime.now();

      // Create owner profile
      final ownerProfile = OwnerProfile(
        id: userId,
        name: state.ownerName!,
        profilePicture: state.ownerProfilePicture,
        bio: state.ownerBio,
        location: state.ownerLocation,
        petIds: [], // Will be updated after creating pet
        createdAt: now,
        updatedAt: now,
      );

      await _ownerRepository.createOwnerProfile(ownerProfile);

      // Create pet profile
      final petProfile = PetProfile(
        id: '', // Will be auto-generated
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
        createdAt: now,
        updatedAt: now,
      );

      final petId = await _petRepository.createPetProfile(petProfile);

      // Update owner with pet ID
      await _ownerRepository.addPetToOwner(userId, petId);

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
  final ownerRepository = ref.read(ownerRepositoryProvider);
  final petRepository = ref.read(petRepositoryProvider);
  return OnboardingNotifier(ownerRepository, petRepository);
});

// Pet Repository Provider (placeholder)
final petRepositoryProvider = Provider<PetRepository>((ref) {
  return PetRepository();
});

// Placeholder PetRepository class
class PetRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createPetProfile(PetProfile profile) async {
    try {
      // Create the pet document in Firestore
      final docRef = await _firestore.collection('pets').add({
        'ownerId': profile.ownerId,
        'name': profile.name,
        'age': profile.age,
        'breed': profile.breed,
        'size': profile.size,
        'temperament': profile.temperament,
        'vaccinated': profile.vaccinated,
        'fixed': profile.fixed,
        'bio': profile.bio,
        'images': profile.images,
        'geoPoint': profile.geoPoint,
        'createdAt': Timestamp.fromDate(profile.createdAt),
        'updatedAt': Timestamp.fromDate(profile.updatedAt),
      });

      // Return the auto-generated document ID
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create pet profile: $e');
    }
  }
}
