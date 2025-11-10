// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Match _$MatchFromJson(Map<String, dynamic> json) => Match(
      id: json['id'] as String,
      petIdA: json['petIdA'] as String,
      petIdB: json['petIdB'] as String,
      ownerIdA: json['ownerIdA'] as String,
      ownerIdB: json['ownerIdB'] as String,
      createdAt:
          const DateTimeConverter().fromJson(json['createdAt'] as Object),
      lastMessageId: json['lastMessageId'] as String?,
      lastMessageTime: _$JsonConverterFromJson<Object, DateTime>(
          json['lastMessageTime'], const DateTimeConverter().fromJson),
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$MatchToJson(Match instance) => <String, dynamic>{
      'id': instance.id,
      'petIdA': instance.petIdA,
      'petIdB': instance.petIdB,
      'ownerIdA': instance.ownerIdA,
      'ownerIdB': instance.ownerIdB,
      'createdAt': const DateTimeConverter().toJson(instance.createdAt),
      'lastMessageId': instance.lastMessageId,
      'lastMessageTime': _$JsonConverterToJson<Object, DateTime>(
          instance.lastMessageTime, const DateTimeConverter().toJson),
      'isActive': instance.isActive,
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
