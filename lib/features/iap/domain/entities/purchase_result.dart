import 'package:equatable/equatable.dart';

/// Enum representing the status of a purchase
enum PurchaseResultStatus {
  pending,
  purchased,
  error,
  canceled,
  restored,
}

/// Entity representing the result of a purchase attempt
class PurchaseResult extends Equatable {
  final PurchaseResultStatus status;
  final String? purchaseId;
  final String? productId;
  final String? error;
  final int? creditsAwarded;
  final DateTime? purchaseDate;

  const PurchaseResult({
    required this.status,
    this.purchaseId,
    this.productId,
    this.error,
    this.creditsAwarded,
    this.purchaseDate,
  });

  @override
  List<Object?> get props => [
        status,
        purchaseId,
        productId,
        error,
        creditsAwarded,
        purchaseDate,
      ];

  PurchaseResult copyWith({
    PurchaseResultStatus? status,
    String? purchaseId,
    String? productId,
    String? error,
    int? creditsAwarded,
    DateTime? purchaseDate,
  }) {
    return PurchaseResult(
      status: status ?? this.status,
      purchaseId: purchaseId ?? this.purchaseId,
      productId: productId ?? this.productId,
      error: error ?? this.error,
      creditsAwarded: creditsAwarded ?? this.creditsAwarded,
      purchaseDate: purchaseDate ?? this.purchaseDate,
    );
  }

  // Helper methods
  bool get isSuccess => status == PurchaseResultStatus.purchased;
  bool get isError => status == PurchaseResultStatus.error;
  bool get isPending => status == PurchaseResultStatus.pending;
  bool get isCanceled => status == PurchaseResultStatus.canceled;
}
