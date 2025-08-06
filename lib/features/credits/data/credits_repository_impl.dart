import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/core/utils/logger.dart';
import 'package:mycards/di/service_locator.dart';
import 'package:mycards/features/credits/domain/credits_repository.dart';
import 'package:mycards/features/credits/domain/transaction_entiity.dart';
import 'package:mycards/features/credits/data/datasources/credits_remote_datasource.dart';
import 'package:mycards/features/credits/data/models/transaction_model.dart';

class CreditsRepositoryImpl implements CreditsRepository {
  final CreditsRemoteDataSource _remoteDataSource;

  CreditsRepositoryImpl({required CreditsRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<int> getCreditBalance(String userId) async {
    try {
      return await _remoteDataSource.getCreditBalance(userId);
    } catch (e) {
      throw Exception('Failed to get credit balance: $e');
    }
  }

  @override
  Future<List<TransactionEntity>> getTransactionHistory(String userId) async {
    try {
      final transactions =
          await _remoteDataSource.getTransactionHistory(userId);
      return transactions.map((model) => model).toList();
    } catch (e) {
      throw Exception('Failed to get transaction history: $e');
    }
  }

  @override
  Future<bool> purchaseCard(String userId, int amount) async {
    try {
      AppLogger.log("Purchasing card for user $userId with amount $amount",
          tag: "Credit Repository");
      return await _remoteDataSource.purchaseCard(userId, amount);
    } catch (e) {
      throw Exception('Failed to purchase card: $e');
    }
  }

  @override
  Future<void> purchaseCredits(String userId, int amount) async {
    try {
      await _remoteDataSource.purchaseCredits(
          userId, amount, 'in_app_purchase');
    } catch (e) {
      throw Exception('Failed to purchase credits: $e');
    }
  }

  @override
  Future<void> sendCredits(
      String? toEmail, int amount, String? fromEmail) async {
    try {
      // TODO: Implement user lookup by email
      // For now, we'll need to get the user IDs from the email addresses
      // This would typically involve querying the users collection by email

      // Placeholder implementation - you'll need to implement user lookup
      throw UnimplementedError('User lookup by email not yet implemented');
    } catch (e) {
      throw Exception('Failed to send credits: $e');
    }
  }

  // Additional method for sending credits by user ID
  Future<void> sendCreditsById(
      String fromUserId, String toUserId, int amount) async {
    try {
      await _remoteDataSource.sendCredits(fromUserId, toUserId, amount);
    } catch (e) {
      throw Exception('Failed to send credits: $e');
    }
  }
}

// Provider for the repository
final creditsRepositoryProvider = Provider<CreditsRepository>((ref) {
  final firestore = ref.read(fireStoreProvider);
  final remoteDataSource = CreditsRemoteDataSourceImpl(firestore: firestore);
  return CreditsRepositoryImpl(remoteDataSource: remoteDataSource);
});
