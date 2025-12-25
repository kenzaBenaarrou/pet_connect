import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pet_con/data/models/pet_profile.dart';
import 'package:pet_con/data/repositories/pet_api_repository.dart';
import 'package:pet_con/data/repositories/match_api_repository.dart';
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
  final PetApiRepository _petApiRepository;
  final MatchApiRepository _matchApiRepository;
  int? _lastPetId;

  DiscoveryNotifier(
    this.settings,
    this._petApiRepository,
    this._matchApiRepository,
  ) : super(const DiscoveryState()) {
    _loadInitialPets();
  }

  Future<void> _loadInitialPets() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final pets = await _fetchPets();
      log('Loaded initial pets: ${pets.first.toJson()}');
      state = state.copyWith(
        pets: pets,
        isLoading: false,
        hasMore: pets.length == 10, // Assuming 10 is our page size
      );
    } catch (e, stackTrace) {
      log('Error loading initial pets: $e', stackTrace: stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMorePets() async {
    if (state.isLoading || !state.hasMore) return;

    try {
      final morePets = await _fetchPets(lastPetId: _lastPetId);
      state = state.copyWith(
        pets: [...state.pets, ...morePets],
        hasMore: morePets.length == 10,
      );
    } catch (e) {
      // Handle error silently for pagination
      print('Error loading more pets: $e');
    }
  }

  Future<List<PetProfile>> _fetchPets({int? lastPetId}) async {
    try {
      // Get current user location
      await Geolocator.getCurrentPosition();
    } catch (e) {
      throw Exception('Failed to get location: $e');
    }

    // Fetch pets from NestJS API with filters
    final pets = await _petApiRepository.getDiscoveryPets(
      limit: 10,
      minAge: settings.minAge > 0 ? settings.minAge : null,
      maxAge: settings.maxAge < 240 ? settings.maxAge : null,
      sizes: settings.petSizes.length < AppConstants.petSizes.length
          ? settings.petSizes
          : null,
      distance: settings.distance,
      lastPetId: lastPetId,
    );

    if (pets.isNotEmpty) {
      _lastPetId = pets.last.id;
    }

    // Filter out already swiped pets
    final filteredPets =
        pets.where((pet) => !state.swipedPetIds.contains(pet.id)).toList();

    return filteredPets;
  }

  Future<void> likePet(String petId) async {
    try {
      // Add to swiped pets
      state = state.copyWith(
        swipedPetIds: {...state.swipedPetIds, petId},
      );

      // Record the swipe via NestJS API
      await _recordSwipe(petId, SwipeAction.like);

      // Check for match
      final matchId = await _checkForMatch(petId);
      if (matchId != null) {
        _handleMatch(matchId);
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

      // Record the swipe via NestJS API
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

      // Record the swipe via NestJS API
      await _recordSwipe(petId, SwipeAction.superLike);

      // Super likes could have special handling
      final matchId = await _checkForMatch(petId);
      if (matchId != null) {
        _handleMatch(matchId);
      }
    } catch (e) {
      print('Error super liking pet: $e');
    }
  }

  Future<void> _recordSwipe(String petId, SwipeAction action) async {
    // Record swipe via NestJS API (you'll need to implement this endpoint)
    // For now, we'll just track locally
    // await _matchApiRepository.recordSwipe(petId, action.name);
  }

  Future<String?> _checkForMatch(String likedPetId) async {
    try {
      // Check for match via NestJS API
      // final match = await _matchApiRepository.checkMatch(likedPetId);
      // return match?.id;
      return null; // Implement when backend endpoint is ready
    } catch (e) {
      print('Error checking for match: $e');
      return null;
    }
  }

  void _handleMatch(String matchId) {
    // TODO: Show match dialog or navigate to match screen
    // This could trigger a global event or state change
    print('Match found: $matchId');
  }

  void refresh() {
    state = const DiscoveryState();
    _lastPetId = null;
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
  final petApiRepository = PetApiRepository();
  final matchApiRepository = MatchApiRepository();
  return DiscoveryNotifier(settings, petApiRepository, matchApiRepository);
});
