class TransactionEntity {
  final String? id;
  final String? userId;
  final String? cardId;
  final int? amount;
  final DateTime? createdAt;
  final String? type;
  final String? status;
  final String? description;
  final String? fromUserId;
  final String? toUserId;
  final String? paymentMethod;

  TransactionEntity({
    required this.id,
    required this.userId,
    this.cardId,
    required this.amount,
    required this.createdAt,
    this.type,
    this.status,
    this.description,
    this.fromUserId,
    this.toUserId,
    this.paymentMethod,
  });
}