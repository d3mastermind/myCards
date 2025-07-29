import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/features/credits/data/transaction_entiity.dart';
import 'package:mycards/features/credits/domain/credits_repository.dart';
import 'package:mycards/features/credits/data/credits_repository_impl.dart';
import 'package:mycards/features/home/services/auth_service.dart';

class CreditState {
  final AsyncValue<int> creditBalance;
  final AsyncValue<List<TransactionEntity>> transactionHistory;
  final AsyncValue<void> purchaseStatus;
  final AsyncValue<void> sendStatus;

  const CreditState({
    required this.creditBalance,
    required this.transactionHistory,
    required this.purchaseStatus,
    required this.sendStatus,
  });

  CreditState copyWith({
    AsyncValue<int>? creditBalance,
    AsyncValue<List<TransactionEntity>>? transactionHistory,
    AsyncValue<void>? purchaseStatus,
    AsyncValue<void>? sendStatus,
  }) {
    return CreditState(
      creditBalance: creditBalance ?? this.creditBalance,
      transactionHistory: transactionHistory ?? this.transactionHistory,
      purchaseStatus: purchaseStatus ?? this.purchaseStatus,
      sendStatus: sendStatus ?? this.sendStatus,
    );
  }
}

class CreditNotifier extends StateNotifier<CreditState> {
  final CreditsRepository _repository;
  final AuthService _authService;

  CreditNotifier({
    required CreditsRepository repository,
    required AuthService authService,
  })  : _repository = repository,
        _authService = authService,
        super(const CreditState(
          creditBalance: AsyncValue.loading(),
          transactionHistory: AsyncValue.loading(),
          purchaseStatus: AsyncValue.data(null),
          sendStatus: AsyncValue.data(null),
        ));

  // Get current user ID
  String? get _currentUserId => _authService.currentUser?.uid;

  // Load credit balance
  Future<void> loadCreditBalance() async {
    final userId = _currentUserId;
    if (userId == null) {
      state = state.copyWith(
        creditBalance:
            AsyncValue.error('User not authenticated', StackTrace.current),
      );
      return;
    }

    state = state.copyWith(creditBalance: const AsyncValue.loading());

    try {
      final balance = await _repository.getCreditBalance(userId);
      state = state.copyWith(creditBalance: AsyncValue.data(balance));
    } catch (error, stackTrace) {
      state =
          state.copyWith(creditBalance: AsyncValue.error(error, stackTrace));
    }
  }

  // Load transaction history
  Future<void> loadTransactionHistory() async {
    final userId = _currentUserId;
    if (userId == null) {
      state = state.copyWith(
        transactionHistory:
            AsyncValue.error('User not authenticated', StackTrace.current),
      );
      return;
    }

    state = state.copyWith(transactionHistory: const AsyncValue.loading());

    try {
      final transactions = await _repository.getTransactionHistory(userId);
      state = state.copyWith(transactionHistory: AsyncValue.data(transactions));
    } catch (error, stackTrace) {
      state = state.copyWith(
          transactionHistory: AsyncValue.error(error, stackTrace));
    }
  }

  // Purchase card
  Future<bool> purchaseCard(int amount) async {
    final userId = _currentUserId;
    if (userId == null) {
      return false;
    }

    try {
      final success = await _repository.purchaseCard(userId, amount);

      if (success) {
        // Reload credit balance after successful purchase
        await loadCreditBalance();
        await loadTransactionHistory();
      }

      return success;
    } catch (error, stackTrace) {
      return false;
    }
  }

  // Purchase credits
  Future<void> purchaseCredits(int amount) async {
    final userId = _currentUserId;
    if (userId == null) {
      state = state.copyWith(
        purchaseStatus:
            AsyncValue.error('User not authenticated', StackTrace.current),
      );
      return;
    }

    state = state.copyWith(purchaseStatus: const AsyncValue.loading());

    try {
      await _repository.purchaseCredits(userId, amount);
      state = state.copyWith(purchaseStatus: const AsyncValue.data(null));

      // Reload credit balance after purchase
      await loadCreditBalance();
      await loadTransactionHistory();
    } catch (error, stackTrace) {
      state =
          state.copyWith(purchaseStatus: AsyncValue.error(error, stackTrace));
    }
  }

  // Send credits to another user by email
  Future<void> sendCredits(String toEmail, int amount) async {
    final userId = _currentUserId;
    if (userId == null) {
      state = state.copyWith(
        sendStatus:
            AsyncValue.error('User not authenticated', StackTrace.current),
      );
      return;
    }

    state = state.copyWith(sendStatus: const AsyncValue.loading());

    try {
      await _repository.sendCredits(
          toEmail, amount, _authService.currentUser?.email);
      state = state.copyWith(sendStatus: const AsyncValue.data(null));

      // Reload credit balance and transaction history after sending
      await loadCreditBalance();
      await loadTransactionHistory();
    } catch (error, stackTrace) {
      state = state.copyWith(sendStatus: AsyncValue.error(error, stackTrace));
    }
  }

  // Send credits to another user by user ID
  Future<void> sendCreditsById(String toUserId, int amount) async {
    final userId = _currentUserId;
    if (userId == null) {
      state = state.copyWith(
        sendStatus:
            AsyncValue.error('User not authenticated', StackTrace.current),
      );
      return;
    }

    state = state.copyWith(sendStatus: const AsyncValue.loading());

    try {
      await _repository.sendCreditsById(userId, toUserId, amount);
      state = state.copyWith(sendStatus: const AsyncValue.data(null));

      // Reload credit balance and transaction history after sending
      await loadCreditBalance();
      await loadTransactionHistory();
    } catch (error, stackTrace) {
      state = state.copyWith(sendStatus: AsyncValue.error(error, stackTrace));
    }
  }

  // Refresh all data
  Future<void> refresh() async {
    await Future.wait([
      loadCreditBalance(),
      loadTransactionHistory(),
    ]);
  }

  // Clear purchase status
  void clearPurchaseStatus() {
    state = state.copyWith(purchaseStatus: const AsyncValue.data(null));
  }

  // Clear send status
  void clearSendStatus() {
    state = state.copyWith(sendStatus: const AsyncValue.data(null));
  }
}

// Provider for the credits notifier
final creditsNotifierProvider =
    StateNotifierProvider<CreditNotifier, CreditState>((ref) {
  final repository = ref.read(creditsRepositoryProvider);
  final authService = AuthService();
  return CreditNotifier(repository: repository, authService: authService);
});

// Convenience providers for specific state parts
final creditBalanceProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(creditsNotifierProvider).creditBalance;
});

final creditBalanceValueProvider = Provider<int>((ref) {
  final balanceAsync = ref.watch(creditsNotifierProvider).creditBalance;
  return balanceAsync.when(
    data: (balance) => balance,
    loading: () => 0,
    error: (error, stack) => 0,
  );
});

final transactionHistoryProvider =
    Provider<AsyncValue<List<TransactionEntity>>>((ref) {
  return ref.watch(creditsNotifierProvider).transactionHistory;
});

final purchaseStatusProvider = Provider<AsyncValue<void>>((ref) {
  return ref.watch(creditsNotifierProvider).purchaseStatus;
});

final sendStatusProvider = Provider<AsyncValue<void>>((ref) {
  return ref.watch(creditsNotifierProvider).sendStatus;
});
