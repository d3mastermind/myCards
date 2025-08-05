class UserEntity {
  final String userId;
  final String? email;
  final String? phoneNumber;
  final String? name;
  final int creditBalance;
  final List<String> likedCards;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? profileImageUrl;

  UserEntity({
    required this.userId,
    required this.email,
    this.phoneNumber,
    this.name,
    this.creditBalance = 10, // Default credit balance
    this.likedCards = const [],
    required this.createdAt,
    required this.updatedAt,
    this.profileImageUrl,
  });

  // Create a copy of the user with updated fields
  UserEntity copyWith({
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
    return UserEntity(
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
