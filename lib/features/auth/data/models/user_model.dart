import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String email;
  final String? phoneNumber;
  final String? name;
  final int creditBalance;
  final List<String> purchasedCards;
  final List<String> likedCards;
  final List<String> receivedCards;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.userId,
    required this.email,
    this.phoneNumber,
    this.name,
    this.creditBalance = 10, // Default credit balance
    this.purchasedCards = const [],
    this.likedCards = const [],
    this.receivedCards = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory method to create an instance from Firestore data
  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      userId: id,
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'],
      name: data['name'],
      creditBalance: data['creditBalance'] ?? 10,
      purchasedCards: List<String>.from(data['purchasedCards'] ?? []),
      likedCards: List<String>.from(data['likedCards'] ?? []),
      receivedCards: List<String>.from(data['receivedCards'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
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
    );
  }
}
 