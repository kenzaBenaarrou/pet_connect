import 'package:json_annotation/json_annotation.dart';
import 'package:pet_con/data/models/pet_profile.dart';

part 'user_model.g.dart';

/// Custom User Model for NestJS Backend Authentication
/// Matches Prisma schema structure
@JsonSerializable()
class UserModel {
  /// User ID from NestJS backend database (auto-increment integer)
  final int? id;

  /// User's first name
  final String? firstname;

  /// User's last name
  final String? lastname;

  /// User's email address
  final String? email;

  /// User bio
  final String? bio;

  /// User age
  final int? age;

  /// User gender
  final String? gender;

  /// Profile photo URL
  final String? photo;

  /// Firebase UID (obtained after signInWithCustomToken)
  ///   @JsonKey(includeFromJson: false, includeToJson: false,)

  final String? firebaseUid;

  //pets
  final List<PetProfile>? pets;

  /// JWT token from NestJS backend
  /// This is NOT stored in JSON serialization for security
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? jwtToken;

  /// Firebase custom token (used once for authentication)
  /// This is NOT stored in JSON serialization for security
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? firebaseToken;

  /// Account creation timestamp
  final DateTime? createdAt;

  /// Last update timestamp
  final DateTime? updatedAt;

  const UserModel({
    this.id,
    this.firstname,
    this.lastname,
    this.email,
    this.bio,
    this.age,
    this.gender,
    this.photo,
    this.pets,
    this.firebaseUid,
    this.jwtToken,
    this.firebaseToken,
    this.createdAt,
    this.updatedAt,
  });

  /// Full name getter for convenience
  String get fullName => '$firstname $lastname';

  /// Create UserModel from JSON (from backend response)
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Copy with method for immutable updates
  UserModel copyWith({
    int? id,
    String? firstname,
    String? lastname,
    String? email,
    String? bio,
    int? age,
    String? gender,
    String? photo,
    String? firebaseUid,
    String? jwtToken,
    String? firebaseToken,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      photo: photo ?? this.photo,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      jwtToken: jwtToken ?? this.jwtToken,
      firebaseToken: firebaseToken ?? this.firebaseToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, fullName: $fullName, email: $email, firebaseUid: $firebaseUid)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.firstname == firstname &&
        other.lastname == lastname &&
        other.email == email &&
        other.firebaseUid == firebaseUid;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        firstname.hashCode ^
        lastname.hashCode ^
        email.hashCode ^
        firebaseUid.hashCode;
  }
}
