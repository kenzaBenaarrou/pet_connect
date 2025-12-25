// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PetProfile _$PetProfileFromJson(Map<String, dynamic> json) => PetProfile(
      id: (json['id'] as num?)?.toInt(),
      ownerId: (json['ownerId'] as num?)?.toInt(),
      name: json['name'] as String?,
      age: (json['age'] as num?)?.toInt(),
      breed: json['breed'] as String?,
      size: json['size'] as String?,
      temperament: (json['temperament'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      vaccinated: json['vaccinated'] as bool?,
      fixed: json['fixed'] as bool?,
      bio: json['bio'] as String?,
      images: const ImageListConverter().fromJson(json['images']),
      geoPoint: const GeoPointConverter().fromJson(json['geoPoint']),
      createdAt: _$JsonConverterFromJson<Object, DateTime>(
          json['createdAt'], const DateTimeConverter().fromJson),
      updatedAt: _$JsonConverterFromJson<Object, DateTime>(
          json['updatedAt'], const DateTimeConverter().fromJson),
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
      'images': const ImageListConverter().toJson(instance.images),
      'geoPoint': const GeoPointConverter().toJson(instance.geoPoint),
      'createdAt': _$JsonConverterToJson<Object, DateTime>(
          instance.createdAt, const DateTimeConverter().toJson),
      'updatedAt': _$JsonConverterToJson<Object, DateTime>(
          instance.updatedAt, const DateTimeConverter().toJson),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
