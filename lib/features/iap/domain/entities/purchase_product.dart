import 'package:equatable/equatable.dart';

/// Entity representing a purchasable product
class PurchaseProduct extends Equatable {
  final String id;
  final String title;
  final String description;
  final String price;
  final String currencyCode;
  final int credits;
  final bool isPopular;
  final String? discount;

  const PurchaseProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.currencyCode,
    required this.credits,
    this.isPopular = false,
    this.discount,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        price,
        currencyCode,
        credits,
        isPopular,
        discount,
      ];

  PurchaseProduct copyWith({
    String? id,
    String? title,
    String? description,
    String? price,
    String? currencyCode,
    int? credits,
    bool? isPopular,
    String? discount,
  }) {
    return PurchaseProduct(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      currencyCode: currencyCode ?? this.currencyCode,
      credits: credits ?? this.credits,
      isPopular: isPopular ?? this.isPopular,
      discount: discount ?? this.discount,
    );
  }
}
