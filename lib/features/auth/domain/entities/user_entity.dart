class UserEntity {
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

  UserEntity({
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


  // Create a copy of the user with updated fields
  UserEntity copyWith({
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
    return UserEntity(
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
 