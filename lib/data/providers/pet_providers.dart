
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pet_profile.dart';
import '../repositories/pet_api_repository.dart';
import '../services/firebase_service.dart';
import '../services/secure_storage_service.dart';

/// Example provider showing how to migrate from Firebase to NestJS API
///
/// MIGRATION STRATEGY:
/// 1. Keep Firebase as fallback during transition
/// 2. Gradually move to API calls
/// 3. Eventually remove Firebase code

/// Provider for pet data - using NestJS API
final petDataProvider =
    FutureProvider.family<PetProfile, int>((ref, petId) async {
  // NEW: Using NestJS API
  final petRepo = ref.read(petApiRepositoryProvider);
  return await petRepo.getPet(petId);
});

/// Provider for current user's pets - using NestJS API
final myPetsProvider = FutureProvider<List<PetProfile>>((ref) async {
  // final userId = FirebaseService.currentUserId;
  final userId = await SecureStorageService.getUserId();
  if (userId == null) throw Exception('Not authenticated');

  // NEW: Using NestJS API
  final petRepo = ref.read(petApiRepositoryProvider);
  return await petRepo.getPetsByOwner(userId);
});

/// Provider for discovery pets - using NestJS API
final discoveryPetsProvider =
    FutureProvider.autoDispose<List<PetProfile>>((ref) async {
  // NEW: Using NestJS API
  final petRepo = ref.read(petApiRepositoryProvider);
  return await petRepo.getDiscoveryPets(limit: 10);
});

// ============================================================
// EXAMPLE: Legacy Firebase approach (for reference/fallback)
// ============================================================

/// OLD WAY: Direct Firebase query (keep as fallback during migration)
final legacyMyPetsProvider = StreamProvider<List<PetProfile>>((ref) {
  final userId = FirebaseService.currentUserId;
  if (userId == null) throw Exception('Not authenticated');

  return FirebaseFirestore.instance
      .collection('pets')
      .where('ownerId', isEqualTo: userId)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => PetProfile.fromFirestore(doc)).toList();
  });
});

// ============================================================
// HYBRID APPROACH: Try API first, fallback to Firebase
// ============================================================

/// Example of hybrid approach during migration
final hybridPetsProvider = FutureProvider<List<PetProfile>>((ref) async {
  // final userId = FirebaseService.currentUserId;
  final userId = await SecureStorageService.getUserId();

  if (userId == null) throw Exception('Not authenticated');

  try {
    // Try NestJS API first
    final petRepo = ref.read(petApiRepositoryProvider);
    return await petRepo.getPetsByOwner(userId);
  } catch (e) {
    // Fallback to Firebase
    print('API failed, using Firebase fallback: $e');
    final snapshot = await FirebaseFirestore.instance
        .collection('pets')
        .where('ownerId', isEqualTo: userId)
        .get();
    return snapshot.docs.map((doc) => PetProfile.fromFirestore(doc)).toList();
  }
});
