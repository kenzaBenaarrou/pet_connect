import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../core/utils/json_converters.dart';

part 'pet_profile.g.dart';

@JsonSerializable()
class PetProfile {
  final String id;
  final String ownerId;
  final String name;
  final int age; // in months
  final String breed;
  final String size; // Small, Medium, Large, Extra Large
  final List<String> temperament;
  final bool vaccinated;
  final bool fixed;
  final String? bio;
  final List<String> images;
  @GeoPointConverter()
  final GeoPoint? geoPoint;
  @DateTimeConverter()
  final DateTime createdAt;
  @DateTimeConverter()
  final DateTime updatedAt;

  const PetProfile({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.age,
    required this.breed,
    required this.size,
    required this.temperament,
    required this.vaccinated,
    required this.fixed,
    this.bio,
    required this.images,
    this.geoPoint,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PetProfile.fromJson(Map<String, dynamic> json) =>
      _$PetProfileFromJson(json);

  Map<String, dynamic> toJson() => _$PetProfileToJson(this);

  factory PetProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PetProfile.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id'); // Don't include ID in Firestore document
    return json;
  }

  // Computed properties
  String get ageText {
    if (age < 12) {
      return '$age months';
    } else {
      final years = age ~/ 12;
      final months = age % 12;
      if (months == 0) {
        return '$years ${years == 1 ? 'year' : 'years'}';
      } else {
        return '$years ${years == 1 ? 'year' : 'years'}, $months ${months == 1 ? 'month' : 'months'}';
      }
    }
  }

  String get primaryImage => images.isNotEmpty ? images.first : '';

  PetProfile copyWith({
    String? id,
    String? ownerId,
    String? name,
    int? age,
    String? breed,
    String? size,
    List<String>? temperament,
    bool? vaccinated,
    bool? fixed,
    String? bio,
    List<String>? images,
    GeoPoint? geoPoint,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PetProfile(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      age: age ?? this.age,
      breed: breed ?? this.breed,
      size: size ?? this.size,
      temperament: temperament ?? this.temperament,
      vaccinated: vaccinated ?? this.vaccinated,
      fixed: fixed ?? this.fixed,
      bio: bio ?? this.bio,
      images: images ?? this.images,
      geoPoint: geoPoint ?? this.geoPoint,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PetProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PetProfile(id: $id, name: $name, breed: $breed, age: $age)';
  }
}
