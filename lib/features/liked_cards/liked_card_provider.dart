import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';
import 'package:mycards/features/app_user/app_user_provider.dart';

class LikedCardsNotifier extends StateNotifier<List<String>> {
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isInitialized = false;

  LikedCardsNotifier(this._ref) : super([]) {
    // Don't load immediately, wait for user to be available
    _initializeWhenUserAvailable();
  }

  // Helper method to get user-friendly Firebase error messages
  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'permission-denied':
        return 'Access denied. Please check your permissions.';
      case 'unavailable':
        return 'Network error. Please check your connection.';
      case 'deadline-exceeded':
        return 'Request timeout. Please try again.';
      case 'not-found':
        return 'User not found.';
      default:
        return 'Database error. Please try again.';
    }
  }

  // Get current user ID from app user provider
  String? get _currentUserId {
    final appUser = AppUserService.instance.currentUser;
    return appUser?.userId;
  }

  // Initialize when user becomes available
  void _initializeWhenUserAvailable() {
    // Check if user is already available
    final currentUser = AppUserService.instance.currentUser;
    if (currentUser != null && !_isInitialized) {
      _isInitialized = true;
      _loadLikedCards();
      return;
    }
  }

  // Load liked cards from Firestore
  Future<void> _loadLikedCards() async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        print('No user available for loading liked cards');
        state = [];
        return;
      }

      print('Loading liked cards for user: $userId');
      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final likedCards = List<String>.from(data['likedCards'] ?? []);
        print(
            'Loaded ${likedCards.length} liked cards from firestore: $likedCards');
        state = likedCards;
      } else {
        print('No user document found or no liked cards');
        state = [];
      }
    } on FirebaseException catch (e) {
      print('Error loading liked cards: $e');

      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Failed to load liked cards'),
        description: Text(_getFirebaseErrorMessage(e.code)),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      rethrow;
    } catch (e) {
      print('Error loading liked cards: $e');

      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Failed to load liked cards'),
        description: Text('An unexpected error occurred'),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      state = [];
    }
  }

  // Toggle like status for a card
  Future<void> toggleLike(String cardId) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        print('User not authenticated');
        return;
      }

      // Update local state first
      final currentLikedCards = List<String>.from(state);
      final isCurrentlyLiked = currentLikedCards.contains(cardId);

      if (isCurrentlyLiked) {
        // Remove from liked cards
        currentLikedCards.remove(cardId);
        print('Removed card $cardId from liked cards');
      } else {
        // Add to liked cards
        currentLikedCards.add(cardId);
        print('Added card $cardId to liked cards');
      }

      // Update local state immediately
      state = currentLikedCards;

      // Update Firestore
      await _firestore.collection('users').doc(userId).update({
        'likedCards': currentLikedCards,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Updated Firestore with liked cards: $currentLikedCards');
    } on FirebaseException catch (e) {
      print('Error toggling like: $e');

      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Failed to update like'),
        description: Text(_getFirebaseErrorMessage(e.code)),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      // Revert local state on error
      await _loadLikedCards();
    } catch (e) {
      print('Error toggling like: $e');

      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Failed to update like'),
        description: Text('An unexpected error occurred'),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      // Revert local state on error
      await _loadLikedCards();
    }
  }

  // Check if a card is liked
  bool isLiked(String cardId) {
    return state.contains(cardId);
  }

  // Get all liked card IDs
  List<String> get likedCardIds => state;

  // Refresh liked cards from Firestore
  Future<void> refresh() async {
    print('Refreshing liked cards...');
    await _loadLikedCards();
  }

  // Clear all liked cards
  Future<void> clearLikedCards() async {
    try {
      final userId = _currentUserId;
      if (userId == null) return;

      // Update local state first
      state = [];

      // Clear from Firestore
      await _firestore.collection('users').doc(userId).update({
        'likedCards': [],
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      print('Error clearing liked cards: $e');

      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Failed to clear liked cards'),
        description: Text(_getFirebaseErrorMessage(e.code)),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      await _loadLikedCards(); // Revert on error
    } catch (e) {
      print('Error clearing liked cards: $e');

      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Failed to clear liked cards'),
        description: Text('An unexpected error occurred'),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      await _loadLikedCards(); // Revert on error
    }
  }

  // Force load liked cards (useful for manual refresh)
  Future<void> forceLoad() async {
    print('Force loading liked cards...');
    await _loadLikedCards();
  }
}

// Provider for liked cards
final likedCardsProvider =
    StateNotifierProvider<LikedCardsNotifier, List<String>>(
  (ref) => LikedCardsNotifier(ref),
);

// Convenience provider to check if a specific card is liked
final isCardLikedProvider = Provider.family<bool, String>((ref, cardId) {
  final likedCards = ref.watch(likedCardsProvider);
  return likedCards.contains(cardId);
});
