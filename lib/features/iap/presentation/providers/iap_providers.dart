import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/features/iap/data/datasources/iap_datasource.dart';
import 'package:mycards/features/iap/domain/services/iap_service.dart';
import 'package:mycards/features/iap/domain/entities/purchase_product.dart';
import 'package:mycards/features/iap/domain/entities/purchase_result.dart';
import 'package:mycards/features/credits/data/credits_repository_impl.dart';
import 'package:mycards/features/home/services/auth_service.dart';

/// Provider for IAP data source
final iapDataSourceProvider = Provider<IAPDataSource>((ref) {
  return IAPDataSourceImpl();
});

/// Provider for IAP service
final iapServiceProvider = Provider<IAPService>((ref) {
  final iapDataSource = ref.read(iapDataSourceProvider);
  final creditsRepository = ref.read(creditsRepositoryProvider);
  final authService = AuthService();

  return IAPService(
    iapDataSource: iapDataSource,
    creditsRepository: creditsRepository,
    authService: authService,
  );
});

/// Provider for IAP availability
final iapAvailabilityProvider = FutureProvider<bool>((ref) async {
  final iapService = ref.read(iapServiceProvider);
  return await iapService.isAvailable();
});

/// Provider for available products
final iapProductsProvider = FutureProvider<List<PurchaseProduct>>((ref) async {
  final iapService = ref.read(iapServiceProvider);

  try {
    print('🔍 Starting IAP products loading...');

    // Initialize IAP first
    print('🔍 Initializing IAP...');
    await iapService.initialize();
    print('✅ IAP initialized successfully');

    // Then get products (this will automatically use test mode if enabled)
    print('🔍 Loading products...');
    final products = await iapService.getProducts();
    print('✅ Products loaded: ${products.length} products found');

    return products;
  } catch (e, stackTrace) {
    print('❌ Error loading IAP products: $e');
    print('Stack trace: $stackTrace');
    rethrow;
  }
});

/// State notifier for managing IAP state
class IAPNotifier extends StateNotifier<AsyncValue<PurchaseResult?>> {
  final IAPService _iapService;
  StreamSubscription<PurchaseResult>? _purchaseResultSubscription;

  IAPNotifier(this._iapService) : super(const AsyncValue.data(null));

  /// Initialize IAP
  Future<void> initialize() async {
    try {
      print('🔍 Initializing IAP in notifier...');
      await _iapService.initialize();
      print('✅ IAP initialized in notifier');

      // Listen to purchase results from the service
      _purchaseResultSubscription = _iapService.purchaseResultStream.listen(
        (result) {
          print('📱 Purchase result received: ${result.status}');
          state = AsyncValue.data(result);
        },
        onError: (error) {
          print('❌ Purchase stream error: $error');
          state = AsyncValue.error(error, StackTrace.current);
        },
      );
    } catch (e, stackTrace) {
      print('❌ Error initializing IAP in notifier: $e');
      print('Stack trace: $stackTrace');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Purchase a product
  Future<void> purchaseProduct(String productId) async {
    state = const AsyncValue.loading();

    try {
      final result = await _iapService.purchaseProduct(productId);

      // Handle immediate results (test mode)
      if (result.status == PurchaseResultStatus.purchased) {
        print('📱 Immediate purchase success: ${result.productId}');
        state = AsyncValue.data(result);
      } else if (result.status == PurchaseResultStatus.error) {
        print('📱 Immediate purchase error: ${result.error}');
        state = AsyncValue.data(result);
      }
      // For pending status, wait for stream updates
    } catch (e, stackTrace) {
      print('📱 Purchase exception: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Restore purchases
  Future<void> restorePurchases() async {
    state = const AsyncValue.loading();

    try {
      await _iapService.restorePurchases();
      // Results will be updated through the stream listener
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Clear the current state
  void clearState() {
    state = const AsyncValue.data(null);
  }

  @override
  void dispose() {
    _purchaseResultSubscription?.cancel();
    _iapService.dispose();
    super.dispose();
  }
}

/// Provider for IAP notifier
final iapNotifierProvider =
    StateNotifierProvider<IAPNotifier, AsyncValue<PurchaseResult?>>((ref) {
  final iapService = ref.read(iapServiceProvider);
  final notifier = IAPNotifier(iapService);

  // Initialize IAP when the provider is created
  notifier.initialize();

  return notifier;
});

/// Convenience provider for purchase result
final purchaseResultProvider = Provider<AsyncValue<PurchaseResult?>>((ref) {
  return ref.watch(iapNotifierProvider);
});
