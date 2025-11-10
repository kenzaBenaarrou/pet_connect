import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../core/utils/json_converters.dart';

part 'owner_profile.g.dart';

@JsonSerializable()
class OwnerProfile {
  final String id;
  final String name;
  final String? profilePicture;
  final String? bio;
  @GeoPointConverter()
  final GeoPoint? location;
  final List<String> petIds;
  @DateTimeConverter()
  final DateTime createdAt;
  @DateTimeConverter()
  final DateTime updatedAt;

  const OwnerProfile({
    required this.id,
    required this.name,
    this.profilePicture,
    this.bio,
    this.location,
    required this.petIds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OwnerProfile.fromJson(Map<String, dynamic> json) =>
      _$OwnerProfileFromJson(json);

  Map<String, dynamic> toJson() => _$OwnerProfileToJson(this);

  factory OwnerProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OwnerProfile.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id'); // Don't include ID in Firestore document
    return json;
  }

  OwnerProfile copyWith({
    String? id,
    String? name,
    String? profilePicture,
    String? bio,
    GeoPoint? location,
    List<String>? petIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OwnerProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      profilePicture: profilePicture ?? this.profilePicture,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      petIds: petIds ?? this.petIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OwnerProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'OwnerProfile(id: $id, name: $name, petIds: $petIds)';
  }
}
