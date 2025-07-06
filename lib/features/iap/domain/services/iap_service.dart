import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mycards/features/iap/data/datasources/iap_datasource.dart';
import 'package:mycards/features/iap/domain/entities/purchase_product.dart';
import 'package:mycards/features/iap/domain/entities/purchase_result.dart';
import 'package:mycards/features/credits/data/credits_repository.dart';
import 'package:mycards/services/auth_service.dart';

/// Service for handling in-app purchases and credit integration
class IAPService {
  final IAPDataSource _iapDataSource;
  final CreditsRepository _creditsRepository;
  final AuthService _authService;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  final StreamController<PurchaseResult> _purchaseResultController =
      StreamController<PurchaseResult>.broadcast();

  IAPService({
    required IAPDataSource iapDataSource,
    required CreditsRepository creditsRepository,
    required AuthService authService,
  })  : _iapDataSource = iapDataSource,
        _creditsRepository = creditsRepository,
        _authService = authService;

  /// Stream of purchase results
  Stream<PurchaseResult> get purchaseResultStream =>
      _purchaseResultController.stream;

  /// Initialize the IAP service
  Future<void> initialize() async {
    await _iapDataSource.initialize();

    // Listen to purchase updates
    _purchaseSubscription = _iapDataSource.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (error) {
        print('Purchase stream error: $error');
      },
    );
  }

  /// Check if IAP is available
  Future<bool> isAvailable() async {
    return await _iapDataSource.isAvailable();
  }

  /// Get available products
  Future<List<PurchaseProduct>> getProducts() async {
    final products = await _iapDataSource.getProducts();
    return products.map((model) => model.toEntity()).toList();
  }

  /// Purchase a product
  Future<PurchaseResult> purchaseProduct(String productId) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      return PurchaseResult(
        status: PurchaseResultStatus.error,
        productId: productId,
        error: 'User not authenticated',
      );
    }

    final result = await _iapDataSource.purchaseProduct(productId);

    // Handle different result statuses
    switch (result.status) {
      case PurchaseResultStatus.purchased:
        // This happens in test mode - handle immediately
        if (result.creditsAwarded != null) {
          print(
              '🧪 TEST MODE: Awarding ${result.creditsAwarded} credits immediately');
          try {
            await _creditsRepository.purchaseCredits(
                userId, result.creditsAwarded!);
            print('✅ TEST MODE: Credits awarded successfully');
            // Emit success result through the stream for UI updates
            _purchaseResultController.add(result);
          } catch (e) {
            print('❌ TEST MODE: Failed to award credits: $e');
            // Emit error result through the stream
            _purchaseResultController.add(PurchaseResult(
              status: PurchaseResultStatus.error,
              productId: productId,
              error: 'Failed to award credits: $e',
            ));
          }
        }
        break;

      case PurchaseResultStatus.pending:
        // This happens in live mode - emit pending state and wait for stream updates
        print(
            '🔄 LIVE MODE: Purchase pending, waiting for Google Play confirmation');
        _purchaseResultController.add(result);
        break;

      case PurchaseResultStatus.error:
        // Emit error immediately
        print('❌ Purchase failed: ${result.error}');
        _purchaseResultController.add(result);
        break;

      case PurchaseResultStatus.canceled:
        // Emit canceled immediately
        print('🚫 Purchase canceled');
        _purchaseResultController.add(result);
        break;

      default:
        // Emit any other status
        _purchaseResultController.add(result);
        break;
    }

    return result;
  }

  /// Restore purchases
  Future<void> restorePurchases() async {
    await _iapDataSource.restorePurchases();
  }

  /// Handle purchase updates from the store
  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchaseDetails in purchaseDetailsList) {
      await _processPurchase(purchaseDetails);
    }
  }

  /// Process a single purchase
  Future<void> _processPurchase(PurchaseDetails purchaseDetails) async {
    try {
      switch (purchaseDetails.status) {
        case PurchaseStatus.purchased:
          await _handleSuccessfulPurchase(purchaseDetails);
          break;
        case PurchaseStatus.restored:
          await _handleRestoredPurchase(purchaseDetails);
          break;
        case PurchaseStatus.pending:
          print('Purchase pending: ${purchaseDetails.productID}');
          _purchaseResultController.add(PurchaseResult(
            status: PurchaseResultStatus.pending,
            productId: purchaseDetails.productID,
            purchaseDate: DateTime.now(),
          ));
          break;
        case PurchaseStatus.error:
          print('Purchase error: ${purchaseDetails.error}');
          _purchaseResultController.add(PurchaseResult(
            status: PurchaseResultStatus.error,
            productId: purchaseDetails.productID,
            error: purchaseDetails.error?.message ?? 'Unknown error',
          ));
          break;
        case PurchaseStatus.canceled:
          print('Purchase canceled: ${purchaseDetails.productID}');
          _purchaseResultController.add(PurchaseResult(
            status: PurchaseResultStatus.canceled,
            productId: purchaseDetails.productID,
          ));
          break;
      }
    } catch (e) {
      print('Error processing purchase: $e');
      _purchaseResultController.add(PurchaseResult(
        status: PurchaseResultStatus.error,
        productId: purchaseDetails.productID,
        error: e.toString(),
      ));
    }
  }

  /// Handle successful purchase
  Future<void> _handleSuccessfulPurchase(
      PurchaseDetails purchaseDetails) async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        print(
            'No authenticated user for purchase: ${purchaseDetails.productID}');
        _purchaseResultController.add(PurchaseResult(
          status: PurchaseResultStatus.error,
          productId: purchaseDetails.productID,
          error: 'User not authenticated',
        ));
        return;
      }

      // Get credits for this product
      final credits = _getCreditsForProduct(purchaseDetails.productID);
      if (credits == 0) {
        print(
            'No credits configured for product: ${purchaseDetails.productID}');
        _purchaseResultController.add(PurchaseResult(
          status: PurchaseResultStatus.error,
          productId: purchaseDetails.productID,
          error: 'No credits configured for this product',
        ));
        return;
      }

      // Award credits to user
      await _creditsRepository.purchaseCredits(userId, credits);

      // Complete the purchase
      await _iapDataSource.completePurchase(purchaseDetails);

      print(
          'Purchase completed successfully: ${purchaseDetails.productID} - $credits credits awarded');

      // Emit successful purchase result
      _purchaseResultController.add(PurchaseResult(
        status: PurchaseResultStatus.purchased,
        productId: purchaseDetails.productID,
        creditsAwarded: credits,
        purchaseDate: DateTime.now(),
      ));
    } catch (e) {
      print('Error handling successful purchase: $e');
      _purchaseResultController.add(PurchaseResult(
        status: PurchaseResultStatus.error,
        productId: purchaseDetails.productID,
        error: e.toString(),
      ));
    }
  }

  /// Handle restored purchase
  Future<void> _handleRestoredPurchase(PurchaseDetails purchaseDetails) async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        print(
            'No authenticated user for restored purchase: ${purchaseDetails.productID}');
        _purchaseResultController.add(PurchaseResult(
          status: PurchaseResultStatus.error,
          productId: purchaseDetails.productID,
          error: 'User not authenticated',
        ));
        return;
      }

      // For restored purchases, we might want to verify if the user already has these credits
      // For now, we'll just complete the purchase without awarding credits again
      await _iapDataSource.completePurchase(purchaseDetails);

      print('Purchase restored: ${purchaseDetails.productID}');

      _purchaseResultController.add(PurchaseResult(
        status: PurchaseResultStatus.restored,
        productId: purchaseDetails.productID,
        purchaseDate: DateTime.now(),
      ));
    } catch (e) {
      print('Error handling restored purchase: $e');
      _purchaseResultController.add(PurchaseResult(
        status: PurchaseResultStatus.error,
        productId: purchaseDetails.productID,
        error: e.toString(),
      ));
    }
  }

  /// Get credits amount for a product ID
  int _getCreditsForProduct(String productId) {
    const Map<String, int> productCreditsMap = {
      'credits_10': 10,
      'credits_50': 50,
      'credits_100': 100,
      'credits_500': 500,
      'credits_1000': 1000,
    };

    return productCreditsMap[productId] ?? 0;
  }

  /// Dispose resources
  void dispose() {
    _purchaseSubscription?.cancel();
    _purchaseResultController.close();
    _iapDataSource.dispose();
  }
}
