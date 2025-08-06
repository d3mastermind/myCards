import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/transaction_entiity.dart';

enum TransactionType {
  purchase,
  send,
  receive,
  cardPurchase,
  refund,
}

enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled,
}

class TransactionModel extends TransactionEntity {
  TransactionModel({
    super.id,
    super.userId,
    super.cardId,
    super.amount,
    super.createdAt,
    super.type,
    super.status,
    super.description,
    super.fromUserId,
    super.toUserId,
    super.paymentMethod,
  });

  // Factory method to create an instance from Firestore data
  factory TransactionModel.fromMap(String id, Map<String, dynamic> data) {
    return TransactionModel(
      id: id,
      userId: data['userId'] ?? '',
      cardId: data['cardId'],
      amount: data['amount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      type: data['type'],
      status: data['status'],
      fromUserId: data['fromUserId'],
      toUserId: data['toUserId'],
      description: data['description'],
      paymentMethod: data['paymentMethod'],
    );
  }

  // Method to convert the object to a Firestore-friendly map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'cardId': cardId,
      'amount': amount,
      'createdAt': Timestamp.fromDate(createdAt!),
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'description': description,
      'paymentMethod': paymentMethod,
    };
  }

  // Convert to entity
  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      userId: userId,
      cardId: cardId,
      amount: amount,
      createdAt: createdAt,
      type: type.toString().split('.').last,
      status: status.toString().split('.').last,
    );
  }

  // Create a copy of the transaction with updated fields
  TransactionModel copyWith({
    String? id,
    String? userId,
    String? cardId,
    int? amount,
    DateTime? createdAt,
    TransactionType? type,
    TransactionStatus? status,
    String? fromUserId,
    String? toUserId,
    String? description,
    String? paymentMethod,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      cardId: cardId ?? this.cardId,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      type: type?.toString().split('.').last,
      status: status?.toString().split('.').last,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      description: description ?? this.description,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}
