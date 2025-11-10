// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PetProfile _$PetProfileFromJson(Map<String, dynamic> json) => PetProfile(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      name: json['name'] as String,
      age: (json['age'] as num).toInt(),
      breed: json['breed'] as String,
      size: json['size'] as String,
      temperament: (json['temperament'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      vaccinated: json['vaccinated'] as bool,
      fixed: json['fixed'] as bool,
      bio: json['bio'] as String?,
      images:
          (json['images'] as List<dynamic>).map((e) => e as String).toList(),
      geoPoint: const GeoPointConverter()
          .fromJson(json['geoPoint'] as Map<String, dynamic>?),
      createdAt:
          const DateTimeConverter().fromJson(json['createdAt'] as Object),
      updatedAt:
          const DateTimeConverter().fromJson(json['updatedAt'] as Object),
    );

Map<String, dynamic> _$PetProfileToJson(PetProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ownerId': instance.ownerId,
      'name': instance.name,
      'age': instance.age,
      'breed': instance.breed,
      'size': instance.size,
      'temperament': instance.temperament,
      'vaccinated': instance.vaccinated,
      'fixed': instance.fixed,
      'bio': instance.bio,
      'images': instance.images,
      'geoPoint': const GeoPointConverter().toJson(instance.geoPoint),
      'createdAt': const DateTimeConverter().toJson(instance.createdAt),
      'updatedAt': const DateTimeConverter().toJson(instance.updatedAt),
    };
