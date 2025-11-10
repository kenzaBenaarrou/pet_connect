import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../core/utils/json_converters.dart';

part 'match.g.dart';

@JsonSerializable()
class Match {
  final String id;
  final String petIdA;
  final String petIdB;
  final String ownerIdA;
  final String ownerIdB;
  @DateTimeConverter()
  final DateTime createdAt;
  final String? lastMessageId;
  @DateTimeConverter()
  final DateTime? lastMessageTime;
  final bool isActive;

  const Match({
    required this.id,
    required this.petIdA,
    required this.petIdB,
    required this.ownerIdA,
    required this.ownerIdB,
    required this.createdAt,
    this.lastMessageId,
    this.lastMessageTime,
    this.isActive = true,
  });

  factory Match.fromJson(Map<String, dynamic> json) => _$MatchFromJson(json);

  Map<String, dynamic> toJson() => _$MatchToJson(this);

  factory Match.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Match.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  // Helper methods
  String getOtherPetId(String currentPetId) {
    return currentPetId == petIdA ? petIdB : petIdA;
  }

  String getOtherOwnerId(String currentOwnerId) {
    return currentOwnerId == ownerIdA ? ownerIdB : ownerIdA;
  }

  bool involves(String petId) {
    return petIdA == petId || petIdB == petId;
  }

  Match copyWith({
    String? id,
    String? petIdA,
    String? petIdB,
    String? ownerIdA,
    String? ownerIdB,
    DateTime? createdAt,
    String? lastMessageId,
    DateTime? lastMessageTime,
    bool? isActive,
  }) {
    return Match(
      id: id ?? this.id,
      petIdA: petIdA ?? this.petIdA,
      petIdB: petIdB ?? this.petIdB,
      ownerIdA: ownerIdA ?? this.ownerIdA,
      ownerIdB: ownerIdB ?? this.ownerIdB,
      createdAt: createdAt ?? this.createdAt,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Match && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Match(id: $id, petIdA: $petIdA, petIdB: $petIdB)';
  }
}
