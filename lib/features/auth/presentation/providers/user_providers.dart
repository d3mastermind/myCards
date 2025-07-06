import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/services/user_service.dart';
import '../../data/models/user_model.dart';

// Provider for UserService
final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

// Provider for current user data
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final userService = ref.read(userServiceProvider);
  return await userService.getCurrentUser();
});

// Provider for user credit balance
final userCreditBalanceProvider = FutureProvider<int>((ref) async {
  final user = await ref.read(currentUserProvider.future);
  return user?.creditBalance ?? 0;
});

// Provider for user's purchased cards
final userPurchasedCardsProvider = FutureProvider<List<String>>((ref) async {
  final user = await ref.read(currentUserProvider.future);
  return user?.purchasedCards ?? [];
});

// Provider for user's liked cards
final userLikedCardsProvider = FutureProvider<List<String>>((ref) async {
  final user = await ref.read(currentUserProvider.future);
  return user?.likedCards ?? [];
});

// Provider for user's received cards
final userReceivedCardsProvider = FutureProvider<List<String>>((ref) async {
  final user = await ref.read(currentUserProvider.future);
  return user?.receivedCards ?? [];
});
