import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mycards/features/iap/domain/entities/purchase_product.dart';

/// Model for purchase products, extends the domain entity
class PurchaseProductModel extends PurchaseProduct {
  const PurchaseProductModel({
    required super.id,
    required super.title,
    required super.description,
    required super.price,
    required super.currencyCode,
    required super.credits,
    super.isPopular = false,
    super.discount,
  });

  /// Create from ProductDetails (from in_app_purchase plugin)
  factory PurchaseProductModel.fromProductDetails({
    required ProductDetails productDetails,
    required int credits,
    bool isPopular = false,
    String? discount,
  }) {
    return PurchaseProductModel(
      id: productDetails.id,
      title: productDetails.title,
      description: productDetails.description,
      price: productDetails.price,
      currencyCode: productDetails.currencyCode,
      credits: credits,
      isPopular: isPopular,
      discount: discount,
    );
  }

  /// Create from JSON (for local configuration)
  factory PurchaseProductModel.fromJson(Map<String, dynamic> json) {
    return PurchaseProductModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: json['price'] as String,
      currencyCode: json['currencyCode'] as String,
      credits: json['credits'] as int,
      isPopular: json['isPopular'] as bool? ?? false,
      discount: json['discount'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'currencyCode': currencyCode,
      'credits': credits,
      'isPopular': isPopular,
      'discount': discount,
    };
  }

  /// Create from domain entity
  factory PurchaseProductModel.fromEntity(PurchaseProduct entity) {
    return PurchaseProductModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      price: entity.price,
      currencyCode: entity.currencyCode,
      credits: entity.credits,
      isPopular: entity.isPopular,
      discount: entity.discount,
    );
  }

  /// Convert to domain entity
  PurchaseProduct toEntity() {
    return PurchaseProduct(
      id: id,
      title: title,
      description: description,
      price: price,
      currencyCode: currencyCode,
      credits: credits,
      isPopular: isPopular,
      discount: discount,
    );
  }
}
