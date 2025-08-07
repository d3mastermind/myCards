import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/features/cards/data/card_repository_impl.dart';
import 'package:mycards/features/cards/domain/card_entity.dart';
import 'package:mycards/features/card_screens/card_page_view.dart';
import 'package:mycards/features/edit_screens/card_data_provider.dart';
import 'package:mycards/core/utils/logger.dart';
import 'package:mycards/widgets/loading_indicators/circular_loading_widget.dart';

/// Provider for shared card state
final sharedCardProvider =
    StateNotifierProvider.family<SharedCardNotifier, SharedCardState, String>(
  (ref, shareLinkId) =>
      SharedCardNotifier(ref.read(cardRepositoryProvider), shareLinkId),
);

/// State for shared card loading
class SharedCardState {
  final bool isLoading;
  final CardEntity? card;
  final String? error;

  const SharedCardState({
    this.isLoading = true,
    this.card,
    this.error,
  });

  SharedCardState copyWith({
    bool? isLoading,
    CardEntity? card,
    String? error,
  }) {
    return SharedCardState(
      isLoading: isLoading ?? this.isLoading,
      card: card ?? this.card,
      error: error ?? this.error,
    );
  }
}

/// Notifier for managing shared card state
class SharedCardNotifier extends StateNotifier<SharedCardState> {
  final cardRepository;
  final String shareLinkId;

  SharedCardNotifier(this.cardRepository, this.shareLinkId)
      : super(const SharedCardState()) {
    _loadSharedCard();
  }

  Future<void> _loadSharedCard() async {
    try {
      AppLogger.log('Loading shared card with ID: $shareLinkId',
          tag: 'SharedCardNotifier');

      final card = await cardRepository.getSharedCard(shareLinkId);

      if (card != null) {
        AppLogger.log('Shared card loaded successfully',
            tag: 'SharedCardNotifier');
        state = state.copyWith(
          isLoading: false,
          card: card,
          error: null,
        );
      } else {
        AppLogger.logError('Shared card not found', tag: 'SharedCardNotifier');
        state = state.copyWith(
          isLoading: false,
          error: 'Card not found or may have been removed',
        );
      }
    } catch (e) {
      AppLogger.logError('Error loading shared card: $e',
          tag: 'SharedCardNotifier');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load card. Please check your internet connection.',
      );
    }
  }

  void retry() {
    state = const SharedCardState();
    _loadSharedCard();
  }
}

/// Screen for viewing shared cards via deep links
class SharedCardViewer extends ConsumerWidget {
  final String shareLinkId;

  const SharedCardViewer({
    super.key,
    required this.shareLinkId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharedCardState = ref.watch(sharedCardProvider(shareLinkId));

    if (sharedCardState.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading Card...'),
          backgroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularLoadingWidget(
                colors: [
                  Colors.orange,
                  Colors.orangeAccent,
                  Colors.deepOrange,
                  Colors.red,
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Loading your card...',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (sharedCardState.error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Card Error'),
          backgroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.red,
                ),
                const SizedBox(height: 20),
                Text(
                  'Oops! Something went wrong',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  sharedCardState.error!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        ref
                            .read(sharedCardProvider(shareLinkId).notifier)
                            .retry();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Try Again'),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Go Back',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (sharedCardState.card != null) {
      // Convert CardEntity to CardData for CardPageView
      final cardData = CardData(
        card: sharedCardState.card,
        toName: sharedCardState.card!.toName,
        fromName: sharedCardState.card!.fromName,
        greetingMessage: sharedCardState.card!.greetingMessage,
        customImageUrl: sharedCardState.card!.customImageUrl,
        voiceNoteUrl: sharedCardState.card!.voiceNoteUrl,
        creditsAttached: sharedCardState.card!.creditsAttached,
      );

      return CardPageView(
        cardData: cardData,
        showSave: false, // Don't show save button for shared cards
      );
    }

    // Fallback (should not reach here)
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Viewer'),
        backgroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Something went wrong'),
      ),
    );
  }
}
