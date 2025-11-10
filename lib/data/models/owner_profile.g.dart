// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owner_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OwnerProfile _$OwnerProfileFromJson(Map<String, dynamic> json) => OwnerProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      profilePicture: json['profilePicture'] as String?,
      bio: json['bio'] as String?,
      location: const GeoPointConverter()
          .fromJson(json['location'] as Map<String, dynamic>?),
      petIds:
          (json['petIds'] as List<dynamic>).map((e) => e as String).toList(),
      createdAt:
          const DateTimeConverter().fromJson(json['createdAt'] as Object),
      updatedAt:
          const DateTimeConverter().fromJson(json['updatedAt'] as Object),
    );

Map<String, dynamic> _$OwnerProfileToJson(OwnerProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'profilePicture': instance.profilePicture,
      'bio': instance.bio,
      'location': const GeoPointConverter().toJson(instance.location),
      'petIds': instance.petIds,
      'createdAt': const DateTimeConverter().toJson(instance.createdAt),
      'updatedAt': const DateTimeConverter().toJson(instance.updatedAt),
    };
