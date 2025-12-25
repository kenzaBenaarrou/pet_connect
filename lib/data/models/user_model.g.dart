// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: (json['id'] as num?)?.toInt(),
      firstname: json['firstname'] as String?,
      lastname: json['lastname'] as String?,
      email: json['email'] as String?,
      bio: json['bio'] as String?,
      age: (json['age'] as num?)?.toInt(),
      gender: json['gender'] as String?,
      photo: json['photo'] as String?,
      pets: (json['pets'] as List<dynamic>?)
          ?.map((e) => PetProfile.fromJson(e as Map<String, dynamic>))
          .toList(),
      firebaseUid: json['firebaseUid'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'firstname': instance.firstname,
      'lastname': instance.lastname,
      'email': instance.email,
      'bio': instance.bio,
      'age': instance.age,
      'gender': instance.gender,
      'photo': instance.photo,
      'firebaseUid': instance.firebaseUid,
      'pets': instance.pets,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
