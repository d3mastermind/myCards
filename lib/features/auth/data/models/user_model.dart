import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mycards/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.userId,
    required super.email,
    super.phoneNumber,
    super.name,
    super.creditBalance = 10, // Default credit balance
    super.purchasedCards = const [],
    super.likedCards = const [],
    super.receivedCards = const [],
    required super.createdAt,
    required super.updatedAt,
    super.profileImageUrl,
  });

  // Factory method to create an instance from data
  factory UserModel.fromMap( Map<String, dynamic> data) {
    return UserModel(
      userId: data['userId'],
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'],
      name: data['name'],
      creditBalance: data['creditBalance'] ?? 10,
      purchasedCards: List<String>.from(data['purchasedCards'] ?? []),
      likedCards: List<String>.from(data['likedCards'] ?? []),
      receivedCards: List<String>.from(data['receivedCards'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      profileImageUrl: data['profileImageUrl'],
    );
  }

  // Factory method to create from Firebase with separate userId and data map
  factory UserModel.fromFirebase(String userId, Map<String, dynamic> data) {
    return UserModel(
      userId: userId,
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'],
      name: data['name'],
      creditBalance: data['creditBalance'] ?? 10,
      purchasedCards: List<String>.from(data['purchasedCards'] ?? []),
      likedCards: List<String>.from(data['likedCards'] ?? []),
      receivedCards: List<String>.from(data['receivedCards'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      profileImageUrl: data['profileImageUrl'],
    );
  }

  // Method to convert the object to a Firestore-friendly map
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'phoneNumber': phoneNumber,
      'name': name,
      'creditBalance': creditBalance,
      'purchasedCards': purchasedCards,
      'likedCards': likedCards,
      'receivedCards': receivedCards,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'profileImageUrl': profileImageUrl,
    };
  }

  // Create a copy of the user with updated fields
  UserModel copyWith({
    String? userId,
    String? email,
    String? phoneNumber,
    String? name,
    int? creditBalance,
    List<String>? purchasedCards,
    List<String>? likedCards,
    List<String>? receivedCards,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? profileImageUrl,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      creditBalance: creditBalance ?? this.creditBalance,
      purchasedCards: purchasedCards ?? this.purchasedCards,
      likedCards: likedCards ?? this.likedCards,
      receivedCards: receivedCards ?? this.receivedCards,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
