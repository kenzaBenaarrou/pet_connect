import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// Converter for GeoPoint to/from JSON
class GeoPointConverter implements JsonConverter<GeoPoint?, Object?> {
  const GeoPointConverter();

  @override
  GeoPoint? fromJson(Object? json) {
    if (json == null) return null;

    // If it's already a GeoPoint (from Firestore), return it directly
    if (json is GeoPoint) {
      return json;
    }

    // Handle Map format
    if (json is Map<String, dynamic>) {
      // Handle both direct lat/lng format and nested _latitude/_longitude format
      if (json.containsKey('_latitude') && json.containsKey('_longitude')) {
        return GeoPoint(
          json['_latitude'] as double,
          json['_longitude'] as double,
        );
      } else if (json.containsKey('latitude') &&
          json.containsKey('longitude')) {
        return GeoPoint(
          json['latitude'] as double,
          json['longitude'] as double,
        );
      }
    }
    return null;
  }

  @override
  Map<String, dynamic>? toJson(GeoPoint? geoPoint) {
    if (geoPoint == null) return null;
    return {
      'latitude': geoPoint.latitude,
      'longitude': geoPoint.longitude,
    };
  }
}

/// Converter for DateTime to/from JSON with Firestore Timestamp support
class DateTimeConverter implements JsonConverter<DateTime, Object> {
  const DateTimeConverter();

  @override
  DateTime fromJson(Object json) {
    if (json is Timestamp) {
      return json.toDate();
    } else if (json is String) {
      return DateTime.parse(json);
    } else if (json is Map<String, dynamic>) {
      // Handle Firestore timestamp format
      if (json.containsKey('_seconds') && json.containsKey('_nanoseconds')) {
        final seconds = json['_seconds'] as int;
        final nanoseconds = json['_nanoseconds'] as int;
        return DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + (nanoseconds / 1000000).round(),
        );
      }
    }
    throw ArgumentError('Cannot convert $json to DateTime');
  }

  @override
  Object toJson(DateTime dateTime) => dateTime.toIso8601String();
}

/// Converter for images list - handles both string URLs and image objects from backend
class ImageListConverter implements JsonConverter<List<String>?, Object?> {
  const ImageListConverter();

  @override
  List<String>? fromJson(Object? json) {
    if (json == null) return null;

    if (json is List) {
      return json.map((item) {
        // If item is a string URL, return it directly
        if (item is String) {
          return item;
        }
        // If item is an object with 'url' field (from NestJS backend)
        if (item is Map<String, dynamic> && item.containsKey('url')) {
          return item['url'] as String;
        }
        // Fallback
        return item.toString();
      }).toList();
    }

    return null;
  }

  @override
  List<String>? toJson(List<String>? images) => images;
}
