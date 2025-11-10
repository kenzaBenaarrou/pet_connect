import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_con/data/models/pet_profile.dart';
import 'package:pet_con/data/services/firebase_service.dart';
import 'package:pet_con/core/constants/app_constants.dart';

// Discovery Settings
class DiscoverySettings {
  final int distance;
  final int minAge;
  final int maxAge;
  final List<String> petSizes;

  const DiscoverySettings({
    this.distance = AppConstants.defaultDistance,
    this.minAge = AppConstants.minAge,
    this.maxAge = AppConstants.maxAge,
    this.petSizes = AppConstants.petSizes,
  });

  DiscoverySettings copyWith({
    int? distance,
    int? minAge,
    int? maxAge,
    List<String>? petSizes,
  }) {
    return DiscoverySettings(
      distance: distance ?? this.distance,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      petSizes: petSizes ?? this.petSizes,
    );
  }
}

// Discovery State
class DiscoveryState {
  final List<PetProfile> pets;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final Set<String> swipedPetIds;

  const DiscoveryState({
    this.pets = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.swipedPetIds = const {},
  });

  DiscoveryState copyWith({
    List<PetProfile>? pets,
    bool? isLoading,
    String? error,
    bool? hasMore,
    Set<String>? swipedPetIds,
  }) {
    return DiscoveryState(
      pets: pets ?? this.pets,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      swipedPetIds: swipedPetIds ?? this.swipedPetIds,
    );
  }
}

// Discovery Notifier
class DiscoveryNotifier extends StateNotifier<DiscoveryState> {
  final DiscoverySettings settings;
  DocumentSnapshot? _lastDocument;

  DiscoveryNotifier(this.settings) : super(const DiscoveryState()) {
    _loadInitialPets();
  }

  Future<void> _loadInitialPets() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final pets = await _fetchPets();
      state = state.copyWith(
        pets: pets,
        isLoading: false,
        hasMore: pets.length == 10, // Assuming 10 is our page size
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMorePets() async {
    if (state.isLoading || !state.hasMore) return;

    try {
      final morePets = await _fetchPets(startAfter: _lastDocument);
      state = state.copyWith(
        pets: [...state.pets, ...morePets],
        hasMore: morePets.length == 10,
      );
    } catch (e) {
      // Handle error silently for pagination
      print('Error loading more pets: $e');
    }
  }

  Future<List<PetProfile>> _fetchPets({DocumentSnapshot? startAfter}) async {
    final currentUserId = FirebaseService.currentUserId;
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    // Get current user location (simplified)
    // In a real app, you'd get this from user profile or current location
    try {
      await Geolocator.getCurrentPosition();
    } catch (e) {
      throw Exception('Failed to get location: $e');
    }

    // Build query
    Query query = FirebaseService.petsCollection
        .where('ownerId', isNotEqualTo: currentUserId) // Exclude own pets
        .limit(10);

    // Add filters based on discovery settings
    if (settings.minAge > 0) {
      query = query.where('age', isGreaterThanOrEqualTo: settings.minAge);
    }
    if (settings.maxAge < 240) {
      query = query.where('age', isLessThanOrEqualTo: settings.maxAge);
    }
    if (settings.petSizes.length < AppConstants.petSizes.length) {
      query = query.where('size', whereIn: settings.petSizes);
    }

    // Exclude already swiped pets
    if (state.swipedPetIds.isNotEmpty) {
      query = query.where(FieldPath.documentId,
          whereNotIn: state.swipedPetIds.take(10).toList());
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      _lastDocument = snapshot.docs.last;
    }

    // Convert to PetProfile objects
    final pets =
        snapshot.docs.map((doc) => PetProfile.fromFirestore(doc)).toList();

    // TODO: Filter by distance using geoPoint
    // This would require implementing proper geo-queries

    return pets;
  }

  Future<void> likePet(String petId) async {
    try {
      // Add to swiped pets
      state = state.copyWith(
        swipedPetIds: {...state.swipedPetIds, petId},
      );

      // Record the swipe in Firestore
      await _recordSwipe(petId, SwipeAction.like);

      // Check for match
      final match = await _checkForMatch(petId);
      if (match != null) {
        // Handle match - could trigger a callback or event
        _handleMatch(match);
      }
    } catch (e) {
      print('Error liking pet: $e');
    }
  }

  Future<void> passPet(String petId) async {
    try {
      // Add to swiped pets
      state = state.copyWith(
        swipedPetIds: {...state.swipedPetIds, petId},
      );

      // Record the swipe in Firestore
      await _recordSwipe(petId, SwipeAction.pass);
    } catch (e) {
      print('Error passing pet: $e');
    }
  }

  Future<void> superLikePet(String petId) async {
    try {
      // Add to swiped pets
      state = state.copyWith(
        swipedPetIds: {...state.swipedPetIds, petId},
      );

      // Record the swipe in Firestore
      await _recordSwipe(petId, SwipeAction.superLike);

      // Super likes could have special handling
      // For now, treat as regular like
      final match = await _checkForMatch(petId);
      if (match != null) {
        _handleMatch(match);
      }
    } catch (e) {
      print('Error super liking pet: $e');
    }
  }

  Future<void> _recordSwipe(String petId, SwipeAction action) async {
    final currentUserId = FirebaseService.currentUserId;
    if (currentUserId == null) return;

    await FirebaseService.swipesCollection.add({
      'swiperId': currentUserId,
      'targetPetId': petId,
      'action': action.name,
      'timestamp': DateTime.now(),
    });
  }

  Future<String?> _checkForMatch(String likedPetId) async {
    final currentUserId = FirebaseService.currentUserId;
    if (currentUserId == null) return null;

    // Get the liked pet's owner
    final petDoc = await FirebaseService.petsCollection.doc(likedPetId).get();
    if (!petDoc.exists) return null;

    final petData = petDoc.data() as Map<String, dynamic>?;
    if (petData == null) return null;

    final likedPetOwnerId = petData['ownerId'] as String;

    // Get current user's pets
    final userPetsSnapshot = await FirebaseService.petsCollection
        .where('ownerId', isEqualTo: currentUserId)
        .get();

    // Check if the other user liked any of our pets
    for (final userPetDoc in userPetsSnapshot.docs) {
      final swipeSnapshot = await FirebaseService.swipesCollection
          .where('swiperId', isEqualTo: likedPetOwnerId)
          .where('targetPetId', isEqualTo: userPetDoc.id)
          .where('action', isEqualTo: SwipeAction.like.name)
          .get();

      if (swipeSnapshot.docs.isNotEmpty) {
        // It's a match! Create match document
        final matchDoc = await FirebaseService.matchesCollection.add({
          'petIdA': userPetDoc.id,
          'petIdB': likedPetId,
          'ownerIdA': currentUserId,
          'ownerIdB': likedPetOwnerId,
          'createdAt': DateTime.now(),
          'isActive': true,
        });

        return matchDoc.id;
      }
    }

    return null;
  }

  void _handleMatch(String matchId) {
    // TODO: Show match dialog or navigate to match screen
    // This could trigger a global event or state change
    print('Match found: $matchId');
  }

  void refresh() {
    state = const DiscoveryState();
    _lastDocument = null;
    _loadInitialPets();
  }
}

enum SwipeAction { like, pass, superLike }

// Providers
final discoverySettingsProvider = StateProvider<DiscoverySettings>((ref) {
  return const DiscoverySettings();
});

final discoveryProvider =
    StateNotifierProvider<DiscoveryNotifier, DiscoveryState>((ref) {
  final settings = ref.watch(discoverySettingsProvider);
  return DiscoveryNotifier(settings);
});
