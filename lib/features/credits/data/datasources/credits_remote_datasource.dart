import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

abstract class CreditsRemoteDataSource {
  Future<int> getCreditBalance(String userId);
  Future<List<TransactionModel>> getTransactionHistory(String userId);
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
      final DocumentSnapshot doc = await firestore
          .collection('users')
          .doc(userId)
          .collection('credits')
          .doc('balance')
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        return data?['balance'] ?? 0;
      }
      return 0;
    } catch (e) {
      throw Exception('Failed to get credit balance: $e');
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
        // Get current balance
        final balanceDoc = firestore
            .collection('users')
            .doc(userId)
            .collection('credits')
            .doc('balance');

        final balanceSnapshot = await firestoreTransaction.get(balanceDoc);
        int currentBalance = 0;
        if (balanceSnapshot.exists) {
          final data = balanceSnapshot.data() as Map<String, dynamic>?;
          currentBalance = data?['balance'] ?? 0;
        }
        final newBalance = currentBalance + amount;

        // Update balance
        firestoreTransaction.set(balanceDoc,
            {'balance': newBalance, 'updatedAt': FieldValue.serverTimestamp()});

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
        // Get sender's balance
        final senderBalanceDoc = firestore
            .collection('users')
            .doc(fromUserId)
            .collection('credits')
            .doc('balance');

        final senderBalanceSnapshot =
            await firestoreTransaction.get(senderBalanceDoc);
        int senderCurrentBalance = 0;
        if (senderBalanceSnapshot.exists) {
          final data = senderBalanceSnapshot.data() as Map<String, dynamic>?;
          senderCurrentBalance = data?['balance'] ?? 0;
        }

        if (senderCurrentBalance < amount) {
          throw Exception('Insufficient credits');
        }

        // Get receiver's balance
        final receiverBalanceDoc = firestore
            .collection('users')
            .doc(toUserId)
            .collection('credits')
            .doc('balance');

        final receiverBalanceSnapshot =
            await firestoreTransaction.get(receiverBalanceDoc);
        int receiverCurrentBalance = 0;
        if (receiverBalanceSnapshot.exists) {
          final data = receiverBalanceSnapshot.data() as Map<String, dynamic>?;
          receiverCurrentBalance = data?['balance'] ?? 0;
        }

        // Update balances
        final senderNewBalance = senderCurrentBalance - amount;
        final receiverNewBalance = receiverCurrentBalance + amount;

        firestoreTransaction.set(senderBalanceDoc, {
          'balance': senderNewBalance,
          'updatedAt': FieldValue.serverTimestamp()
        });

        firestoreTransaction.set(receiverBalanceDoc, {
          'balance': receiverNewBalance,
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
      await firestore
          .collection('users')
          .doc(userId)
          .collection('credits')
          .doc('balance')
          .set({
        'balance': newBalance,
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
