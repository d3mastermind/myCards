import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mycards/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.userId,
    required super.email,
    super.phoneNumber,
    super.name,
    super.creditBalance = 10, // Default credit balance
    super.likedCards = const [],
    required super.createdAt,
    required super.updatedAt,
    super.profileImageUrl,
  });

  // Factory method to create an instance from data
  factory UserModel.fromMap(Map<String, dynamic> data) {
    DateTime parseDateTime(dynamic value) {
      if (value == null) {
        return DateTime.now(); // fallback for null values
      } else if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        return DateTime.parse(value);
      } else {
        return DateTime.now(); // fallback
      }
    }

    return UserModel(
      userId: data['userId'],
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'],
      name: data['name'],
      creditBalance: data['creditBalance'] ?? 10,
      likedCards: List<String>.from(data['likedCards'] ?? []),
      createdAt: parseDateTime(data['createdAt']),
      updatedAt: parseDateTime(data['updatedAt']),
      profileImageUrl: data['profileImageUrl'],
    );
  }

  // Factory method to create from Firebase with separate userId and data map
  factory UserModel.fromFirebase(String userId, Map<String, dynamic> data) {
    DateTime parseDateTime(dynamic value) {
      if (value == null) {
        return DateTime.now(); // fallback for null values
      } else if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        return DateTime.parse(value);
      } else {
        return DateTime.now(); // fallback
      }
    }

    return UserModel(
      userId: userId,
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'],
      name: data['name'],
      creditBalance: data['creditBalance'] ?? 10,
      likedCards: List<String>.from(data['likedCards'] ?? []),
      createdAt: parseDateTime(data['createdAt']),
      updatedAt: parseDateTime(data['updatedAt']),
      profileImageUrl: data['profileImageUrl'],
    );
  }

  // Method to convert the object to a Firestore-friendly map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId, // Add userId to the map
      'email': email,
      'phoneNumber': phoneNumber,
      'name': name,
      'creditBalance': creditBalance,

      'likedCards': likedCards,

      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'profileImageUrl': profileImageUrl,
    };
  }

  // Method to convert the object to a storage-friendly map (for Hive/JSON)
  Map<String, dynamic> toStorageMap() {
    return {
      'userId': userId,
      'email': email,
      'phoneNumber': phoneNumber,
      'name': name,
      'creditBalance': creditBalance,
      'likedCards': likedCards,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'profileImageUrl': profileImageUrl,
    };
  }

  // Factory method to create an instance from storage data (handles both Timestamp and string formats)
  factory UserModel.fromStorageMap(Map<String, dynamic> data) {
    DateTime parseDateTime(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        return DateTime.parse(value);
      } else {
        return DateTime.now(); // fallback
      }
    }

    return UserModel(
      userId: data['userId'],
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'],
      name: data['name'],
      creditBalance: data['creditBalance'] ?? 10,
      likedCards: List<String>.from(data['likedCards'] ?? []),
      createdAt: parseDateTime(data['createdAt']),
      updatedAt: parseDateTime(data['updatedAt']),
      profileImageUrl: data['profileImageUrl'],
    );
  }

  // Create a copy of the user with updated fields
  UserModel copyWith({
    String? userId,
    String? email,
    String? phoneNumber,
    String? name,
    int? creditBalance,
    List<String>? likedCards,
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
      likedCards: likedCards ?? this.likedCards,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
