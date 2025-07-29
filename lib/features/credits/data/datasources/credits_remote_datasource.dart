import 'package:cloud_firestore/cloud_firestore.dart';
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
      final DocumentSnapshot doc =
          await firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        return data?['creditBalance'] ?? 0;
      }
      return 0;
    } catch (e) {
      throw Exception('Failed to get credit balance: $e');
    }
  }

  @override
  Future<bool> purchaseCard(String userId, int amount) async {
    try {
      if (amount <= 0) {
        throw Exception('Invalid credit amount');
      }

      // Get current balance
      final currentBalance = await getCreditBalance(userId);

      if (currentBalance < amount) {
        throw Exception('Insufficient credits');
      }

      // Calculate new balance
      final newBalance = currentBalance - amount;

      // Update Firestore
      await firestore.collection('users').doc(userId).update({
        'creditBalance': newBalance,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      throw Exception('Failed to purchase card: $e');
    }
  }

  @override
  Future<void> refreshBalance(String userId) async {
    try {
      // This method is mainly for compatibility
      // The balance is automatically refreshed when getCreditBalance is called
      await getCreditBalance(userId);
    } catch (e) {
      throw Exception('Failed to refresh balance: $e');
    }
  }

  @override
  Future<bool> hasSufficientCredits(String userId, int amount) async {
    try {
      final currentBalance = await getCreditBalance(userId);
      return currentBalance >= amount;
    } catch (e) {
      throw Exception('Failed to check sufficient credits: $e');
    }
  }

  @override
  Future<List<TransactionModel>> getTransactionHistory(String userId) async {
    try {
      final QuerySnapshot snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => TransactionModel.fromMap(
              doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get transaction history: $e');
    }
  }

  @override
  Future<void> purchaseCredits(
      String userId, int amount, String paymentMethod) async {
    try {
      await firestore.runTransaction((firestoreTransaction) async {
        // Get current balance from user document
        final userDoc = firestore.collection('users').doc(userId);
        final userSnapshot = await firestoreTransaction.get(userDoc);

        int currentBalance = 0;
        if (userSnapshot.exists) {
          final data = userSnapshot.data() as Map<String, dynamic>?;
          currentBalance = data?['creditBalance'] ?? 0;
        }

        final newBalance = currentBalance + amount;

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
          type: TransactionType.purchase,
          status: TransactionStatus.completed,
          description: 'Credit purchase',
          paymentMethod: paymentMethod,
        );

        firestoreTransaction.set(transactionDoc, transactionModel.toMap());
      });
    } catch (e) {
      throw Exception('Failed to purchase credits: $e');
    }
  }

  @override
  Future<void> sendCredits(
      String fromUserId, String toUserId, int amount) async {
    try {
      await firestore.runTransaction((firestoreTransaction) async {
        // Get sender's balance from user document
        final senderUserDoc = firestore.collection('users').doc(fromUserId);
        final senderUserSnapshot =
            await firestoreTransaction.get(senderUserDoc);

        int senderCurrentBalance = 0;
        if (senderUserSnapshot.exists) {
          final data = senderUserSnapshot.data() as Map<String, dynamic>?;
          senderCurrentBalance = data?['creditBalance'] ?? 0;
        }

        if (senderCurrentBalance < amount) {
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
        }

        // Update balances in user documents
        final senderNewBalance = senderCurrentBalance - amount;
        final receiverNewBalance = receiverCurrentBalance + amount;

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
          type: TransactionType.send,
          status: TransactionStatus.completed,
          fromUserId: fromUserId,
          toUserId: toUserId,
          description: 'Sent credits to user',
        );

        firestoreTransaction.set(
            senderTransactionDoc, senderTransaction.toMap());

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
          type: TransactionType.receive,
          status: TransactionStatus.completed,
          fromUserId: fromUserId,
          toUserId: toUserId,
          description: 'Received credits from user',
        );

        firestoreTransaction.set(
            receiverTransactionDoc, receiverTransaction.toMap());
      });
    } catch (e) {
      throw Exception('Failed to send credits: $e');
    }
  }

  @override
  Future<void> updateCreditBalance(String userId, int newBalance) async {
    try {
      await firestore.collection('users').doc(userId).update({
        'creditBalance': newBalance,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update credit balance: $e');
    }
  }

  @override
  Future<String> createTransaction(TransactionModel transaction) async {
    try {
      final docRef = await firestore
          .collection('users')
          .doc(transaction.userId)
          .collection('transactions')
          .add(transaction.toMap());

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create transaction: $e');
    }
  }
}
