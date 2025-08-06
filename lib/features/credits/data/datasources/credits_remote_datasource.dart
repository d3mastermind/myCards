import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mycards/core/utils/logger.dart';
import '../models/transaction_model.dart';

abstract class CreditsRemoteDataSource {
  Future<int> getCreditBalance(String userId);
  Future<List<TransactionModel>> getTransactionHistory(String userId);
  Future<bool> purchaseCard(String userId, int amount);
  Future<void> refreshBalance(String userId);
  Future<bool> hasSufficientCredits(String userId, int amount);
  Future<void> purchaseCredits(String userId, int amount, String paymentMethod);
  Future<void> sendCredits(String fromUserId, String toUserId, int amount);
  Future<void> updateCreditBalance(String userId, int newBalance);
  Future<String> createTransaction(TransactionModel transaction);
}

class CreditsRemoteDataSourceImpl implements CreditsRemoteDataSource {
  final FirebaseFirestore firestore;

  CreditsRemoteDataSourceImpl({required this.firestore});

  @override
  Future<int> getCreditBalance(String userId) async {
    try {
      AppLogger.log("Getting credit balance for user: $userId",
          tag: "Credit Data Source");

      final DocumentSnapshot doc =
          await firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        final balance = data?['creditBalance'] ?? 0;
        AppLogger.logSuccess("Retrieved balance: $balance for user: $userId",
            tag: "Credit Data Source");
        return balance;
      }

      AppLogger.logWarning("User document not found: $userId",
          tag: "Credit Data Source");
      return 0;
    } on FirebaseException catch (e) {
      AppLogger.logError(
          "Firebase error getting credit balance: ${e.code} - ${e.message}",
          tag: "Credit Data Source");

      switch (e.code) {
        case 'permission-denied':
          throw Exception('Access denied. Please check your permissions.');
        case 'unavailable':
          throw Exception('Network error. Please check your connection.');
        case 'deadline-exceeded':
          throw Exception('Request timeout. Please try again.');
        case 'not-found':
          throw Exception('User not found.');
        default:
          throw Exception('Database error: ${e.message}');
      }
    } catch (e) {
      AppLogger.logError("Unexpected error getting credit balance: $e",
          tag: "Credit Data Source");
      throw Exception('Failed to get credit balance: $e');
    }
  }

  @override
  Future<bool> purchaseCard(String userId, int amount) async {
    try {
      AppLogger.log("Starting card purchase - User: $userId, Amount: $amount",
          tag: "Credit Data Source");

      if (amount <= 0) {
        AppLogger.logError("Invalid credit amount: $amount",
            tag: "Credit Data Source");
        throw Exception('Invalid credit amount');
      }

      await firestore.runTransaction((firestoreTransaction) async {
        // Get current balance from user document
        final userDoc = firestore.collection('users').doc(userId);
        final userSnapshot = await firestoreTransaction.get(userDoc);

        int currentBalance = 0;
        if (userSnapshot.exists) {
          final data = userSnapshot.data() as Map<String, dynamic>?;
          currentBalance = data?['creditBalance'] ?? 0;
          AppLogger.log("Current balance: $currentBalance for user: $userId",
              tag: "Credit Data Source");
        } else {
          AppLogger.logWarning("User document not found: $userId",
              tag: "Credit Data Source");
        }

        if (currentBalance < amount) {
          AppLogger.logError(
              "Insufficient credits - Current: $currentBalance, Required: $amount",
              tag: "Credit Data Source");
          throw Exception('Insufficient credits');
        }

        // Calculate new balance
        final newBalance = currentBalance - amount;
        AppLogger.log("Updating balance from $currentBalance to $newBalance",
            tag: "Credit Data Source");

        // Update balance in user document
        firestoreTransaction.update(userDoc, {
          'creditBalance': newBalance,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Create transaction record
        final transactionDoc = firestore
            .collection('users')
            .doc(userId)
            .collection('transactions')
            .doc();

        final transactionModel = TransactionModel(
          id: transactionDoc.id,
          userId: userId,
          amount: -amount, // Negative for spending
          createdAt: DateTime.now(),
          type: 'purchase',
          status: 'completed',
          description: 'Card purchase',
        );

        firestoreTransaction.set(transactionDoc, transactionModel.toMap());
        AppLogger.log(
            "Transaction record created with ID: ${transactionDoc.id}",
            tag: "Credit Data Source");
      });

      AppLogger.logSuccess(
          "Card purchase completed successfully - User: $userId, Amount: $amount",
          tag: "Credit Data Source");
      return true;
    } on FirebaseException catch (e) {
      AppLogger.logError(
          "Firebase error purchasing card: ${e.code} - ${e.message}",
          tag: "Credit Data Source");

      switch (e.code) {
        case 'permission-denied':
          throw Exception('Access denied. Please check your permissions.');
        case 'unavailable':
          throw Exception('Network error. Please check your connection.');
        case 'deadline-exceeded':
          throw Exception('Request timeout. Please try again.');
        case 'failed-precondition':
          throw Exception('Transaction failed. Please try again.');
        default:
          throw Exception('Database error: ${e.message}');
      }
    } catch (e) {
      AppLogger.logError("Unexpected error purchasing card: $e",
          tag: "Credit Data Source");
      throw Exception('Failed to purchase card: $e');
    }
  }

  @override
  Future<void> refreshBalance(String userId) async {
    try {
      AppLogger.log("Refreshing balance for user: $userId",
          tag: "Credit Data Source");
      // This method is mainly for compatibility
      // The balance is automatically refreshed when getCreditBalance is called
      await getCreditBalance(userId);
      AppLogger.logSuccess("Balance refreshed successfully for user: $userId",
          tag: "Credit Data Source");
    } catch (e) {
      AppLogger.logError("Failed to refresh balance: $e",
          tag: "Credit Data Source");
      throw Exception('Failed to refresh balance: $e');
    }
  }

  @override
  Future<bool> hasSufficientCredits(String userId, int amount) async {
    try {
      AppLogger.log(
          "Checking sufficient credits - User: $userId, Required: $amount",
          tag: "Credit Data Source");
      final currentBalance = await getCreditBalance(userId);
      final hasSufficient = currentBalance >= amount;
      AppLogger.log(
          "Credit check result - Balance: $currentBalance, Required: $amount, Sufficient: $hasSufficient",
          tag: "Credit Data Source");
      return hasSufficient;
    } catch (e) {
      AppLogger.logError("Failed to check sufficient credits: $e",
          tag: "Credit Data Source");
      throw Exception('Failed to check sufficient credits: $e');
    }
  }

  @override
  Future<List<TransactionModel>> getTransactionHistory(String userId) async {
    try {
      AppLogger.log("Getting transaction history for user: $userId",
          tag: "Credit Data Source");

      final QuerySnapshot snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      final transactions = snapshot.docs
          .map((doc) => TransactionModel.fromMap(
              doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      AppLogger.log("Transactions: ${transactions.map((e) => e.toMap())}",
          tag: "Credit Data Source");
      AppLogger.logSuccess(
          "Retrieved ${transactions.length} transactions for user: $userId",
          tag: "Credit Data Source");
      return transactions;
    } on FirebaseException catch (e) {
      AppLogger.logError(
          "Firebase error getting transaction history: ${e.code} - ${e.message}",
          tag: "Credit Data Source");

      switch (e.code) {
        case 'permission-denied':
          throw Exception('Access denied. Please check your permissions.');
        case 'unavailable':
          throw Exception('Network error. Please check your connection.');
        case 'deadline-exceeded':
          throw Exception('Request timeout. Please try again.');
        default:
          throw Exception('Database error: ${e.message}');
      }
    } catch (e) {
      AppLogger.logError("Unexpected error getting transaction history: $e",
          tag: "Credit Data Source");
      throw Exception('Failed to get transaction history: $e');
    }
  }

  @override
  Future<void> purchaseCredits(
      String userId, int amount, String paymentMethod) async {
    try {
      AppLogger.log(
          "Starting credit purchase - User: $userId, Amount: $amount, Payment: $paymentMethod",
          tag: "Credit Data Source");

      await firestore.runTransaction((firestoreTransaction) async {
        // Get current balance from user document
        final userDoc = firestore.collection('users').doc(userId);
        final userSnapshot = await firestoreTransaction.get(userDoc);

        int currentBalance = 0;
        if (userSnapshot.exists) {
          final data = userSnapshot.data() as Map<String, dynamic>?;
          currentBalance = data?['creditBalance'] ?? 0;
          AppLogger.log("Current balance: $currentBalance for user: $userId",
              tag: "Credit Data Source");
        } else {
          AppLogger.logWarning("User document not found: $userId",
              tag: "Credit Data Source");
        }

        final newBalance = currentBalance + amount;
        AppLogger.log("Updating balance from $currentBalance to $newBalance",
            tag: "Credit Data Source");

        // Update balance in user document
        firestoreTransaction.update(userDoc, {
          'creditBalance': newBalance,
          'updatedAt': FieldValue.serverTimestamp()
        });

        // Create transaction record
        final transactionDoc = firestore
            .collection('users')
            .doc(userId)
            .collection('transactions')
            .doc();

        final transactionModel = TransactionModel(
          id: transactionDoc.id,
          userId: userId,
          amount: amount,
          createdAt: DateTime.now(),
          type: 'purchase',
          status: 'completed',
          description: 'Credit purchase',
          paymentMethod: paymentMethod,
        );

        firestoreTransaction.set(transactionDoc, transactionModel.toMap());
        AppLogger.log(
            "Transaction record created with ID: ${transactionDoc.id}",
            tag: "Credit Data Source");
      });

      AppLogger.logSuccess(
          "Credit purchase completed successfully - User: $userId, Amount: $amount",
          tag: "Credit Data Source");
    } catch (e) {
      AppLogger.logError("Failed to purchase credits: $e",
          tag: "Credit Data Source");
      throw Exception('Failed to purchase credits: $e');
    }
  }

  @override
  Future<void> sendCredits(
      String fromUserId, String toUserId, int amount) async {
    try {
      AppLogger.log(
          "Starting credit transfer - From: $fromUserId, To: $toUserId, Amount: $amount",
          tag: "Credit Data Source");

      await firestore.runTransaction((firestoreTransaction) async {
        // Get sender's balance from user document
        final senderUserDoc = firestore.collection('users').doc(fromUserId);
        final senderUserSnapshot =
            await firestoreTransaction.get(senderUserDoc);

        int senderCurrentBalance = 0;
        if (senderUserSnapshot.exists) {
          final data = senderUserSnapshot.data() as Map<String, dynamic>?;
          senderCurrentBalance = data?['creditBalance'] ?? 0;
          AppLogger.log(
              "Sender balance: $senderCurrentBalance for user: $fromUserId",
              tag: "Credit Data Source");
        } else {
          AppLogger.logWarning("Sender document not found: $fromUserId",
              tag: "Credit Data Source");
        }

        if (senderCurrentBalance < amount) {
          AppLogger.logError(
              "Insufficient credits for sender - Balance: $senderCurrentBalance, Required: $amount",
              tag: "Credit Data Source");
          throw Exception('Insufficient credits');
        }

        // Get receiver's balance from user document
        final receiverUserDoc = firestore.collection('users').doc(toUserId);
        final receiverUserSnapshot =
            await firestoreTransaction.get(receiverUserDoc);

        int receiverCurrentBalance = 0;
        if (receiverUserSnapshot.exists) {
          final data = receiverUserSnapshot.data() as Map<String, dynamic>?;
          receiverCurrentBalance = data?['creditBalance'] ?? 0;
          AppLogger.log(
              "Receiver balance: $receiverCurrentBalance for user: $toUserId",
              tag: "Credit Data Source");
        } else {
          AppLogger.logWarning("Receiver document not found: $toUserId",
              tag: "Credit Data Source");
        }

        // Update balances in user documents
        final senderNewBalance = senderCurrentBalance - amount;
        final receiverNewBalance = receiverCurrentBalance + amount;

        AppLogger.log(
            "Updating balances - Sender: $senderCurrentBalance → $senderNewBalance, Receiver: $receiverCurrentBalance → $receiverNewBalance",
            tag: "Credit Data Source");

        firestoreTransaction.update(senderUserDoc, {
          'creditBalance': senderNewBalance,
          'updatedAt': FieldValue.serverTimestamp()
        });

        firestoreTransaction.update(receiverUserDoc, {
          'creditBalance': receiverNewBalance,
          'updatedAt': FieldValue.serverTimestamp()
        });

        // Create sender transaction record
        final senderTransactionDoc = firestore
            .collection('users')
            .doc(fromUserId)
            .collection('transactions')
            .doc();

        final senderTransaction = TransactionModel(
          id: senderTransactionDoc.id,
          userId: fromUserId,
          amount: -amount, // Negative for outgoing
          createdAt: DateTime.now(),
          type: 'send',
          status: 'completed',
          fromUserId: fromUserId,
          toUserId: toUserId,
          description: 'Sent credits to user',
        );

        firestoreTransaction.set(
            senderTransactionDoc, senderTransaction.toMap());
        AppLogger.log(
            "Sender transaction created with ID: ${senderTransactionDoc.id}",
            tag: "Credit Data Source");

        // Create receiver transaction record
        final receiverTransactionDoc = firestore
            .collection('users')
            .doc(toUserId)
            .collection('transactions')
            .doc();

        final receiverTransaction = TransactionModel(
          id: receiverTransactionDoc.id,
          userId: toUserId,
          amount: amount, // Positive for incoming
          createdAt: DateTime.now(),
          type: 'receive',
          status: 'completed',
          fromUserId: fromUserId,
          toUserId: toUserId,
          description: 'Received credits from user',
        );

        firestoreTransaction.set(
            receiverTransactionDoc, receiverTransaction.toMap());
        AppLogger.log(
            "Receiver transaction created with ID: ${receiverTransactionDoc.id}",
            tag: "Credit Data Source");
      });

      AppLogger.logSuccess(
          "Credit transfer completed successfully - From: $fromUserId, To: $toUserId, Amount: $amount",
          tag: "Credit Data Source");
    } catch (e) {
      AppLogger.logError("Failed to send credits: $e",
          tag: "Credit Data Source");
      throw Exception('Failed to send credits: $e');
    }
  }

  @override
  Future<void> updateCreditBalance(String userId, int newBalance) async {
    try {
      AppLogger.log(
          "Updating credit balance - User: $userId, New Balance: $newBalance",
          tag: "Credit Data Source");

      await firestore.collection('users').doc(userId).update({
        'creditBalance': newBalance,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      AppLogger.logSuccess(
          "Credit balance updated successfully - User: $userId, New Balance: $newBalance",
          tag: "Credit Data Source");
    } catch (e) {
      AppLogger.logError("Failed to update credit balance: $e",
          tag: "Credit Data Source");
      throw Exception('Failed to update credit balance: $e');
    }
  }

  @override
  Future<String> createTransaction(TransactionModel transaction) async {
    try {
      AppLogger.log(
          "Creating transaction - User: ${transaction.userId}, Amount: ${transaction.amount}, Type: ${transaction.type}",
          tag: "Credit Data Source");

      final docRef = await firestore
          .collection('users')
          .doc(transaction.userId)
          .collection('transactions')
          .add(transaction.toMap());

      AppLogger.logSuccess(
          "Transaction created successfully - ID: ${docRef.id}, User: ${transaction.userId}",
          tag: "Credit Data Source");
      return docRef.id;
    } catch (e) {
      AppLogger.logError("Failed to create transaction: $e",
          tag: "Credit Data Source");
      throw Exception('Failed to create transaction: $e');
    }
  }
}
