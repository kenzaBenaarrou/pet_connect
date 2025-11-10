import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_con/data/models/owner_profile.dart';
import 'package:pet_con/data/services/firebase_service.dart';

final ownerRepositoryProvider = Provider<OwnerRepository>((ref) {
  return OwnerRepository();
});

class OwnerRepository {
  final CollectionReference _collection = FirebaseService.ownersCollection;

  // Get owner profile by ID
  Future<OwnerProfile?> getOwnerProfile(String ownerId) async {
    try {
      final doc = await _collection.doc(ownerId).get();
      if (doc.exists) {
        return OwnerProfile.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get owner profile: $e');
    }
  }

  // Create new owner profile
  Future<void> createOwnerProfile(OwnerProfile profile) async {
    try {
      await _collection.doc(profile.id).set(profile.toFirestore());
    } catch (e) {
      throw Exception('Failed to create owner profile: $e');
    }
  }

  // Update owner profile
  Future<void> updateOwnerProfile(OwnerProfile profile) async {
    try {
      await _collection.doc(profile.id).update(profile.toFirestore());
    } catch (e) {
      throw Exception('Failed to update owner profile: $e');
    }
  }

  // Delete owner profile
  Future<void> deleteOwnerProfile(String ownerId) async {
    try {
      await _collection.doc(ownerId).delete();
    } catch (e) {
      throw Exception('Failed to delete owner profile: $e');
    }
  }

  // Stream owner profile
  Stream<OwnerProfile?> streamOwnerProfile(String ownerId) {
    return _collection.doc(ownerId).snapshots().map((doc) {
      if (doc.exists) {
        return OwnerProfile.fromFirestore(doc);
      }
      return null;
    });
  }

  // Add pet to owner's pet list
  Future<void> addPetToOwner(String ownerId, String petId) async {
    try {
      await _collection.doc(ownerId).update({
        'petIds': FieldValue.arrayUnion([petId]),
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Failed to add pet to owner: $e');
    }
  }

  // Remove pet from owner's pet list
  Future<void> removePetFromOwner(String ownerId, String petId) async {
    try {
      await _collection.doc(ownerId).update({
        'petIds': FieldValue.arrayRemove([petId]),
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Failed to remove pet from owner: $e');
    }
  }

  // Update owner location
  Future<void> updateOwnerLocation(String ownerId, GeoPoint location) async {
    try {
      await _collection.doc(ownerId).update({
        'location': location,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Failed to update owner location: $e');
    }
  }
}
