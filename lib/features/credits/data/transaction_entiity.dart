class TransactionEntity {
  final String id;
  final String userId;
  final String? cardId;
  final int amount;
  final DateTime createdAt;
  final String? type;
  final String? status;

  TransactionEntity({
    required this.id,
    required this.userId,
    this.cardId,
    required this.amount,
    required this.createdAt,
    this.type,
    this.status,
  });
}