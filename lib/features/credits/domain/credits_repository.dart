import 'dart:async';
import 'package:mycards/features/credits/domain/transaction_entiity.dart';

abstract class CreditsRepository {
  Future<int> getCreditBalance(String userId);
  Future<List<TransactionEntity>> getTransactionHistory(String userId);
  Future<bool> purchaseCard(String userId, int amount);
  Future<void> purchaseCredits(String userId, int amount);
  Future<void> sendCredits(String? toEmail, int amount, String? fromEmail);
  Future<void> sendCreditsById(String fromUserId, String toUserId, int amount);
  Future<bool> attachCreditsToCard(String userId, int amount);
}
