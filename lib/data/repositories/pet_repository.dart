import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;
import '../models/pet_profile.dart';
import '../services/firebase_service.dart';

class PetRepository {
  final FirebaseService _firebaseService;

  PetRepository(this._firebaseService);

  Future<String> createPet(PetProfile pet) async {
    try {
      final docRef = await FirebaseFirestore.instance
          .collection('pets')
          .add(pet.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create pet: $e');
    }
  }

  Future<PetProfile?> getPet(String petId) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('pets').doc(petId).get();

      if (doc.exists) {
        return PetProfile.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get pet: $e');
    }
  }

  Future<List<PetProfile>> getPetsByOwner(String ownerId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('pets')
          .where('ownerId', isEqualTo: ownerId)
          .get();

      return querySnapshot.docs
          .map((doc) => PetProfile.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get pets by owner: $e');
    }
  }

  Future<List<PetProfile>> getDiscoveryPets({
    String? excludeOwnerId,
    GeoPoint? userLocation,
    double maxDistance = 50.0,
    int? minAge,
    int? maxAge,
    List<String>? breeds,
    List<String>? sizes,
    int limit = 20,
  }) async {
    try {
      Query query = FirebaseFirestore.instance.collection('pets');

      // Exclude user's own pets
      if (excludeOwnerId != null) {
        query = query.where('ownerId', isNotEqualTo: excludeOwnerId);
      }

      // Add age filters
      if (minAge != null) {
        query = query.where('age', isGreaterThanOrEqualTo: minAge);
      }
      if (maxAge != null) {
        query = query.where('age', isLessThanOrEqualTo: maxAge);
      }

      // Add breed filter
      if (breeds != null && breeds.isNotEmpty) {
        query = query.where('breed', whereIn: breeds);
      }

      // Add size filter
      if (sizes != null && sizes.isNotEmpty) {
        query = query.where('size', whereIn: sizes);
      }

      query = query.limit(limit);

      final querySnapshot = await query.get();

      List<PetProfile> pets = querySnapshot.docs
          .map((doc) => PetProfile.fromFirestore(doc))
          .toList();

      // Filter by distance if location is provided
      if (userLocation != null) {
        pets = pets.where((pet) {
          if (pet.geoPoint == null) return false;
          final distance = _calculateDistance(
            userLocation.latitude,
            userLocation.longitude,
            pet.geoPoint!.latitude,
            pet.geoPoint!.longitude,
          );
          return distance <= maxDistance;
        }).toList();
      }

      return pets;
    } catch (e) {
      throw Exception('Failed to get discovery pets: $e');
    }
  }

  Future<void> updatePet(PetProfile pet) async {
    try {
      await FirebaseFirestore.instance
          .collection('pets')
          .doc(pet.id)
          .update(pet.toFirestore());
    } catch (e) {
      throw Exception('Failed to update pet: $e');
    }
  }

  Future<void> deletePet(String petId) async {
    try {
      await FirebaseFirestore.instance.collection('pets').doc(petId).delete();
    } catch (e) {
      throw Exception('Failed to delete pet: $e');
    }
  }

  // Helper method to calculate distance between two points
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth radius in kilometers

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.asin(math.sqrt(a));

    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * (math.pi / 180);
  }
}
