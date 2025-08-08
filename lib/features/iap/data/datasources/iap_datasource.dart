import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mycards/features/iap/data/models/purchase_product_model.dart';
import 'package:mycards/features/iap/domain/entities/purchase_result.dart';

/// Data source for handling in-app purchases
abstract class IAPDataSource {
  Future<bool> isAvailable();
  Future<List<PurchaseProductModel>> getProducts();
  Future<PurchaseResult> purchaseProduct(String productId);
  Future<void> restorePurchases();
  Stream<List<PurchaseDetails>> get purchaseStream;
  Future<void> completePurchase(PurchaseDetails purchaseDetails);
  Future<void> initialize();
  void dispose();
}

class IAPDataSourceImpl implements IAPDataSource {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  final StreamController<List<PurchaseDetails>> _purchaseController =
      StreamController<List<PurchaseDetails>>.broadcast();

  // Product IDs - these should match your Google Play Console products
  static const Map<String, int> _productCreditsMap = {
    'credits_10': 10,
    'credits_50': 50,
    'credits_100': 100,
    'credits_500': 500,
    'credits_1000': 1000,
  };

  static const Map<String, bool> _popularProducts = {
    'credits_100': true, // Mark 100 credits as popular
  };

  // 🔧 PRODUCTION SWITCH: Set to false when deploying to production
  // ================================
  // TEST MODE (true):  Uses mock products, simulates purchases
  // LIVE MODE (false): Uses real Google Play products and billing
  // ================================
  static const bool _testMode = false; // ⚠️ CHANGE TO FALSE FOR PRODUCTION ⚠️

  // Mock products for testing
  static const List<Map<String, dynamic>> _mockProducts = [
    {
      'id': 'credits_10',
      'title': '10 Credits (TEST)',
      'description': 'Get 10 credits for testing',
      'price': '\$0.99',
      'currencyCode': 'USD',
    },
    {
      'id': 'credits_50',
      'title': '50 Credits (TEST)',
      'description': 'Get 50 credits for testing',
      'price': '\$4.99',
      'currencyCode': 'USD',
    },
    {
      'id': 'credits_100',
      'title': '100 Credits (TEST)',
      'description': 'Get 100 credits for testing - Best Value!',
      'price': '\$9.99',
      'currencyCode': 'USD',
    },
    {
      'id': 'credits_500',
      'title': '500 Credits (TEST)',
      'description': 'Get 500 credits for testing',
      'price': '\$39.99',
      'currencyCode': 'USD',
    },
    {
      'id': 'credits_1000',
      'title': '1000 Credits (TEST)',
      'description': 'Get 1000 credits for testing - Maximum Value!',
      'price': '\$79.99',
      'currencyCode': 'USD',
    },
  ];

  @override
  Future<void> initialize() async {
    // Initialize the connection
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      throw Exception('In-app purchases not available');
    }

    // Listen to purchase updates
    _subscription = _inAppPurchase.purchaseStream.listen(
      (List<PurchaseDetails> purchaseDetailsList) {
        _purchaseController.add(purchaseDetailsList);
        _handlePurchaseUpdates(purchaseDetailsList);
      },
      onDone: () {
        _subscription.cancel();
      },
      onError: (error) {
        print('Purchase stream error: $error');
      },
    );

    // Note: enablePendingPurchases is handled automatically in newer versions
    print('IAP initialized successfully');
  }

  @override
  Future<bool> isAvailable() async {
    return await _inAppPurchase.isAvailable();
  }

  @override
  Future<List<PurchaseProductModel>> getProducts() async {
    // Check if we're in test mode - always use mock products in test mode
    if (_testMode) {
      print('🧪 TEST MODE: Using mock products for development');
      return _mockProducts.map((mockProduct) {
        final int credits = _productCreditsMap[mockProduct['id']] ?? 0;
        final bool isPopular = _popularProducts[mockProduct['id']] ?? false;

        return PurchaseProductModel(
          id: mockProduct['id'],
          title: mockProduct['title'],
          description: mockProduct['description'],
          price: mockProduct['price'],
          currencyCode: mockProduct['currencyCode'],
          credits: credits,
          isPopular: isPopular,
        );
      }).toList();
    }

    // Live mode IAP flow with timeout and better error handling
    try {
      print('🔄 LIVE MODE: Loading products from Google Play Store...');
      final Set<String> productIds = _productCreditsMap.keys.toSet();

      // Add timeout to prevent hanging
      final ProductDetailsResponse response = await _inAppPurchase
          .queryProductDetails(productIds)
          .timeout(const Duration(seconds: 30));

      if (response.error != null) {
        print('❌ Product query error: ${response.error!.message}');
        throw Exception('Failed to load products: ${response.error!.message}');
      }

      if (response.productDetails.isEmpty) {
        print('❌ No products found in Google Play Console');
        throw Exception('No products found. Please ensure:\n'
            '• Products are configured in Google Play Console\n'
            '• App is uploaded to Play Console (internal testing)\n'
            '• Product IDs match exactly: ${productIds.join(', ')}\n'
            '• Products are in "Active" status');
      }

      print(
          '✅ LIVE MODE: Loaded ${response.productDetails.length} products from Play Store');

      return response.productDetails.map((productDetails) {
        final int credits = _productCreditsMap[productDetails.id] ?? 0;
        final bool isPopular = _popularProducts[productDetails.id] ?? false;

        return PurchaseProductModel.fromProductDetails(
          productDetails: productDetails,
          credits: credits,
          isPopular: isPopular,
        );
      }).toList();
    } on TimeoutException {
      print('❌ Product loading timed out');
      throw Exception(
          'Request timed out. Please check your internet connection and try again.');
    } catch (e) {
      print('❌ Error loading products: $e');
      rethrow;
    }
  }

  @override
  Future<PurchaseResult> purchaseProduct(String productId) async {
    try {
      // Check if we're in test mode - always simulate purchases in test mode
      if (_testMode) {
        print('🧪 TEST MODE: Simulating purchase for product: $productId');
        // Simulate a short delay
        await Future.delayed(const Duration(milliseconds: 500));

        // Simulate a successful purchase
        return PurchaseResult(
          status: PurchaseResultStatus.purchased,
          productId: productId,
          purchaseDate: DateTime.now(),
          creditsAwarded: _productCreditsMap[productId] ?? 0,
        );
      }

      // Live mode IAP flow with better error handling
      print('🔄 LIVE MODE: Initiating purchase for product: $productId');

      try {
        final Set<String> productIds = {productId};
        final ProductDetailsResponse response = await _inAppPurchase
            .queryProductDetails(productIds)
            .timeout(const Duration(seconds: 15));

        if (response.error != null) {
          print('❌ Product query error: ${response.error!.message}');
          return PurchaseResult(
            status: PurchaseResultStatus.error,
            productId: productId,
            error: 'Failed to find product: ${response.error!.message}',
          );
        }

        if (response.productDetails.isEmpty) {
          print('❌ Product not found: $productId');
          return PurchaseResult(
            status: PurchaseResultStatus.error,
            productId: productId,
            error: 'Product "$productId" not found in Google Play Console',
          );
        }

        final ProductDetails productDetails = response.productDetails.first;
        final PurchaseParam purchaseParam =
            PurchaseParam(productDetails: productDetails);

        print('🔄 LIVE MODE: Calling Google Play billing API...');
        final bool success = await _inAppPurchase
            .buyConsumable(purchaseParam: purchaseParam)
            .timeout(const Duration(seconds: 30));

        if (success) {
          print(
              '✅ LIVE MODE: Purchase initiated successfully, waiting for confirmation...');
          return PurchaseResult(
            status: PurchaseResultStatus.pending,
            productId: productId,
            purchaseDate: DateTime.now(),
          );
        } else {
          print('❌ Failed to initiate purchase');
          return PurchaseResult(
            status: PurchaseResultStatus.error,
            productId: productId,
            error: 'Failed to initiate purchase. Please try again.',
          );
        }
      } on TimeoutException {
        print('❌ Purchase initiation timed out');
        return PurchaseResult(
          status: PurchaseResultStatus.error,
          productId: productId,
          error:
              'Purchase timed out. Please check your connection and try again.',
        );
      } on PlatformException catch (e) {
        print('❌ Platform error during purchase: ${e.message}');
        return PurchaseResult(
          status: PurchaseResultStatus.error,
          productId: productId,
          error: 'Purchase failed: ${e.message ?? "Unknown platform error"}',
        );
      }
    } catch (e) {
      return PurchaseResult(
        status: PurchaseResultStatus.error,
        productId: productId,
        error: e.toString(),
      );
    }
  }

  @override
  Future<void> restorePurchases() async {
    await _inAppPurchase.restorePurchases();
  }

  @override
  Stream<List<PurchaseDetails>> get purchaseStream =>
      _purchaseController.stream;

  @override
  Future<void> completePurchase(PurchaseDetails purchaseDetails) async {
    await _inAppPurchase.completePurchase(purchaseDetails);
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (PurchaseDetails purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          print('Purchase pending: ${purchaseDetails.productID}');
          break;
        case PurchaseStatus.purchased:
          print('Purchase completed: ${purchaseDetails.productID}');
          // The purchase will be handled by the service layer
          break;
        case PurchaseStatus.error:
          print('Purchase error: ${purchaseDetails.error}');
          break;
        case PurchaseStatus.canceled:
          print('Purchase canceled: ${purchaseDetails.productID}');
          break;
        case PurchaseStatus.restored:
          print('Purchase restored: ${purchaseDetails.productID}');
          break;
      }
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    _purchaseController.close();
  }
}
