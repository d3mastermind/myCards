import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';
import 'package:mycards/features/cards/data/card_repository_impl.dart';
import 'package:mycards/features/cards/domain/card_entity.dart';
import 'package:mycards/features/cards/domain/card_repository.dart';
import 'package:mycards/features/liked_cards/liked_card_provider.dart';
import 'package:mycards/features/templates/domain/entities/template_entity.dart';
import 'package:mycards/features/templates/presentation/providers/all_templates.dart';
import 'package:mycards/features/app_user/app_user_provider.dart';
import 'package:mycards/core/utils/logger.dart';

class MyCardsScreenState {
  final AsyncValue<List<TemplateEntity>> likedCards;
  final AsyncValue<List<CardEntity>> purchasedCards;
  final AsyncValue<List<CardEntity>> receivedCards;
  final bool isLoading;

  MyCardsScreenState({
    required this.likedCards,
    required this.purchasedCards,
    required this.receivedCards,
    this.isLoading = false,
  });

  MyCardsScreenState copyWith({
    AsyncValue<List<TemplateEntity>>? likedCards,
    AsyncValue<List<CardEntity>>? purchasedCards,
    AsyncValue<List<CardEntity>>? receivedCards,
    bool? isLoading,
  }) {
    return MyCardsScreenState(
      likedCards: likedCards ?? this.likedCards,
      purchasedCards: purchasedCards ?? this.purchasedCards,
      receivedCards: receivedCards ?? this.receivedCards,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class MyCardsScreenViewModel extends StateNotifier<MyCardsScreenState> {
  final Ref _ref;
  final CardRepository _cardRepository;
  final AppUserService _appUserService;

  MyCardsScreenViewModel(this._ref, this._cardRepository)
      : _appUserService = AppUserService.instance,
        super(MyCardsScreenState(
          likedCards: const AsyncValue.loading(),
          purchasedCards: const AsyncValue.loading(),
          receivedCards: const AsyncValue.loading(),
        )) {
    _initialize();
  }

  void _initialize() {
    // Wait for auth state to be properly initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAfterFrame();
    });
  }

  void _initializeAfterFrame() async {
    // Wait for AppUserService to be properly initialized
    await _appUserService.waitForInitialization();

    // Load data if user is available
    final user = _appUserService.currentUser;
    AppLogger.log('Initializing with user: ${user?.userId}',
        tag: 'MyCardsScreenViewModel');

    if (user != null) {
      AppLogger.log('User available, loading data...',
          tag: 'MyCardsScreenViewModel');
      _loadAllData();
    } else {
      AppLogger.log('No user available, trying to force refresh...',
          tag: 'MyCardsScreenViewModel');

      // Try to force refresh user data
      await _appUserService.forceRefreshUserData();
      final refreshedUser = _appUserService.currentUser;

      if (refreshedUser != null) {
        AppLogger.log('User data refreshed, loading data...',
            tag: 'MyCardsScreenViewModel');
        _loadAllData();
      } else {
        AppLogger.log('Still no user available after refresh',
            tag: 'MyCardsScreenViewModel');
        // Set empty states for all sections
        state = state.copyWith(
          likedCards: const AsyncValue.data([]),
          purchasedCards: const AsyncValue.data([]),
          receivedCards: const AsyncValue.data([]),
          isLoading: false,
        );
      }
    }
  }

  Future<void> _loadAllData() async {
    AppLogger.log('Loading all data...', tag: 'MyCardsScreenViewModel');
    state = state.copyWith(isLoading: true);

    try {
      await Future.wait([
        _loadPurchasedCards(),
        _loadReceivedCards(),
        _loadLikedCards(),
      ]);
      AppLogger.log('All data loaded successfully',
          tag: 'MyCardsScreenViewModel');
    } catch (e) {
      AppLogger.logError('Error loading all data: $e',
          tag: 'MyCardsScreenViewModel');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _loadLikedCards() async {
    try {
      AppLogger.log('Loading liked cards...', tag: 'MyCardsScreenViewModel');
      // Get liked card IDs
      final likedCardIds = _ref.read(likedCardsProvider);
      AppLogger.log(
          'Found ${likedCardIds.length} liked card IDs: $likedCardIds',
          tag: 'MyCardsScreenViewModel');

      // Watch all templates provider
      final allTemplatesAsync = _ref.watch(allTemplatesProvider);

      allTemplatesAsync.when(
        data: (templates) {
          AppLogger.log('Found ${templates.length} total templates',
              tag: 'MyCardsScreenViewModel');

          final likedTemplates = templates
              .where((template) => likedCardIds.contains(template.templateId))
              .toList();

          AppLogger.log('Found ${likedTemplates.length} liked templates',
              tag: 'MyCardsScreenViewModel');

          state = state.copyWith(
            likedCards: AsyncValue.data(likedTemplates),
          );
        },
        loading: () {
          AppLogger.log('Templates still loading...',
              tag: 'MyCardsScreenViewModel');
          state = state.copyWith(
            likedCards: const AsyncValue.loading(),
          );
        },
        error: (error, stackTrace) {
          AppLogger.logError('Templates error: $error',
              tag: 'MyCardsScreenViewModel');
          state = state.copyWith(
            likedCards: AsyncValue.error(error, stackTrace),
          );
        },
      );
    } catch (e) {
      AppLogger.logError('Error loading liked cards: $e',
          tag: 'MyCardsScreenViewModel');
      state = state.copyWith(
        likedCards: AsyncValue.error(e.toString(), StackTrace.current),
      );
    }
  }

  Future<void> _loadPurchasedCards() async {
    try {
      AppLogger.log('Loading purchased cards...',
          tag: 'MyCardsScreenViewModel');
      final user = _appUserService.currentUser;
      if (user == null) {
        AppLogger.log('No user for purchased cards',
            tag: 'MyCardsScreenViewModel');
        state = state.copyWith(
          purchasedCards: const AsyncValue.data([]),
        );
        return;
      }

      final purchasedCards =
          await _cardRepository.getPurchasedCards(user.userId);
      AppLogger.log('Found ${purchasedCards.length} purchased cards',
          tag: 'MyCardsScreenViewModel');
      state = state.copyWith(
        purchasedCards: AsyncValue.data(purchasedCards),
      );
    } catch (e) {
      AppLogger.logError('Error loading purchased cards: $e',
          tag: 'MyCardsScreenViewModel');
      state = state.copyWith(
        purchasedCards: AsyncValue.error(e.toString(), StackTrace.current),
      );
    }
  }

  Future<void> _loadReceivedCards() async {
    try {
      AppLogger.log('Loading received cards...', tag: 'MyCardsScreenViewModel');
      final user = _appUserService.currentUser;
      if (user == null) {
        AppLogger.log('No user for received cards',
            tag: 'MyCardsScreenViewModel');
        state = state.copyWith(
          receivedCards: const AsyncValue.data([]),
        );
        return;
      }

      final receivedCards = await _cardRepository.getReceivedCards(user.userId);
      AppLogger.log('Found ${receivedCards.length} received cards',
          tag: 'MyCardsScreenViewModel');
      state = state.copyWith(
        receivedCards: AsyncValue.data(receivedCards),
      );
    } catch (e) {
      AppLogger.logError('Error loading received cards: $e',
          tag: 'MyCardsScreenViewModel');
      state = state.copyWith(
        receivedCards: AsyncValue.error(e.toString(), StackTrace.current),
      );
    }
  }

  Future<void> refresh() async {
    AppLogger.log('Refreshing MyCardsScreen data...',
        tag: 'MyCardsScreenViewModel');

    // Wait for AppUserService to be properly initialized
    await _appUserService.waitForInitialization();

    final user = _appUserService.currentUser;
    if (user != null) {
      await _loadAllData();
    } else {
      AppLogger.log('No user available for refresh, trying force refresh...',
          tag: 'MyCardsScreenViewModel');

      // Try to force refresh user data
      await _appUserService.forceRefreshUserData();
      final refreshedUser = _appUserService.currentUser;

      if (refreshedUser != null) {
        AppLogger.log('User data refreshed, loading data...',
            tag: 'MyCardsScreenViewModel');
        await _loadAllData();
      } else {
        AppLogger.log('Still no user available after force refresh',
            tag: 'MyCardsScreenViewModel');
        state = state.copyWith(
          likedCards: const AsyncValue.data([]),
          purchasedCards: const AsyncValue.data([]),
          receivedCards: const AsyncValue.data([]),
          isLoading: false,
        );
      }
    }
  }

  Future<void> refreshLikedCards() async {
    await _loadLikedCards();
  }

  Future<void> refreshPurchasedCards() async {
    await _loadPurchasedCards();
  }

  Future<void> refreshReceivedCards() async {
    await _loadReceivedCards();
  }

  // Helper methods for UI
  bool get hasLikedCards => state.likedCards.value?.isNotEmpty ?? false;
  bool get hasPurchasedCards => state.purchasedCards.value?.isNotEmpty ?? false;
  bool get hasReceivedCards => state.receivedCards.value?.isNotEmpty ?? false;

  List<TemplateEntity> get likedCards => state.likedCards.value ?? [];
  List<CardEntity> get purchasedCards => state.purchasedCards.value ?? [];
  List<CardEntity> get receivedCards => state.receivedCards.value ?? [];
}

// Provider for MyCardsScreenViewModel
final myCardsScreenViewModelProvider =
    StateNotifierProvider<MyCardsScreenViewModel, MyCardsScreenState>(
  (ref) {
    final cardRepository = ref.read(cardRepositoryProvider);
    return MyCardsScreenViewModel(ref, cardRepository);
  },
);
