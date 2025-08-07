import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';
import 'package:mycards/features/cards/domain/card_entity.dart';
import 'package:mycards/core/utils/logger.dart';

abstract class CardDatasource {
  Future<void> createCard(CardEntity card, String userId);
  Future<void> updateCard(
      String cardId, String userId, Map<String, dynamic> updates);
  Future<CardEntity> getCard(String id, String userId);
  Future<List<CardEntity>> getPurchasedCards(String userId);
  Future<List<CardEntity>> getReceivedCards(String userId);
  Future<String> createShareLink(String cardId, CardEntity card, String userId);
  Future<CardEntity?> getSharedCard(String shareLinkId);
  Future<void> addToReceivedCards(String shareLinkId, String receiverId);
}

class CardDatasourceImpl implements CardDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
        return 'Card not found.';
      default:
        return 'Database error. Please try again.';
    }
  }

  @override
  Future<void> createCard(CardEntity card, String userId) async {
    try {
      // Create card in purchasedCards subcollection
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('purchasedCards')
          .doc(card.id)
          .set({
        'templateId': card.templateId,
        'senderId': card.senderId,
        'receiverId': card.receiverId,
        'receiverEmail': card.receiverEmail,
        'receiverPhone': card.receiverPhone,
        'toName': card.toName,
        'fromName': card.fromName,
        'greetingMessage': card.greetingMessage,
        'customImageUrl': card.customImageUrl,
        'voiceNoteUrl': card.voiceNoteUrl,
        'createdAt': card.createdAt,
        'isOpened': card.isOpened,
        'creditsAttached': card.creditsAttached,
        'shareLinkId': card.shareLinkId,
        'isShared': card.isShared,
        'frontImageUrl': card.frontImageUrl,
      });
    } on FirebaseException catch (e) {
      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Failed to create card'),
        description: Text(_getFirebaseErrorMessage(e.code)),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      throw Exception('Failed to create card: $e');
    } catch (e) {
      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Failed to create card'),
        description: Text('An unexpected error occurred'),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      throw Exception('Failed to create card: $e');
    }
  }

  @override
  Future<CardEntity> getCard(String id, String userId) async {
    try {
      // First try to find in purchasedCards
      DocumentSnapshot purchasedDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('purchasedCards')
          .doc(id)
          .get();

      if (purchasedDoc.exists) {
        Map<String, dynamic> data = purchasedDoc.data() as Map<String, dynamic>;
        return CardEntity(
          id: id,
          templateId: data['templateId'],
          senderId: data['senderId'],
          receiverId: data['receiverId'],
          receiverEmail: data['receiverEmail'],
          receiverPhone: data['receiverPhone'],
          toName: data['toName'],
          fromName: data['fromName'],
          greetingMessage: data['greetingMessage'],
          customImageUrl: data['customImageUrl'],
          voiceNoteUrl: data['voiceNoteUrl'],
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          isOpened: data['isOpened'] ?? false,
          creditsAttached: data['creditsAttached'] ?? 0,
          shareLinkId: data['shareLinkId'],
          isShared: data['isShared'] ?? false,
          frontImageUrl: data['frontImageUrl'],
        );
      }

      // If not found in purchasedCards, try receivedCards
      DocumentSnapshot receivedDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('receivedCards')
          .doc(id)
          .get();

      if (receivedDoc.exists) {
        Map<String, dynamic> data = receivedDoc.data() as Map<String, dynamic>;
        return CardEntity(
          id: id,
          templateId: data['templateId'],
          senderId: data['senderId'],
          receiverId: data['receiverId'],
          receiverEmail: data['receiverEmail'],
          receiverPhone: data['receiverPhone'],
          toName: data['toName'],
          fromName: data['fromName'],
          greetingMessage: data['greetingMessage'],
          customImageUrl: data['customImageUrl'],
          voiceNoteUrl: data['voiceNoteUrl'],
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          isOpened: data['isOpened'] ?? false,
          creditsAttached: data['creditsAttached'] ?? 0,
          shareLinkId: data['shareLinkId'],
          isShared: data['isShared'] ?? false,
          frontImageUrl: data['frontImageUrl'],
        );
      }

      throw Exception('Card not found');
    } on FirebaseException catch (e) {
      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Failed to get card'),
        description: Text(_getFirebaseErrorMessage(e.code)),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      throw Exception('Failed to get card: $e');
    } catch (e) {
      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Failed to get card'),
        description: Text('An unexpected error occurred'),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      throw Exception('Failed to get card: $e');
    }
  }

  @override
  Future<List<CardEntity>> getPurchasedCards(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('purchasedCards')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return CardEntity(
          id: doc.id,
          templateId: data['templateId'],
          senderId: data['senderId'],
          receiverId: data['receiverId'],
          receiverEmail: data['receiverEmail'],
          receiverPhone: data['receiverPhone'],
          toName: data['toName'],
          fromName: data['fromName'],
          greetingMessage: data['greetingMessage'],
          customImageUrl: data['customImageUrl'],
          voiceNoteUrl: data['voiceNoteUrl'],
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          isOpened: data['isOpened'] ?? false,
          creditsAttached: data['creditsAttached'] ?? 0,
          shareLinkId: data['shareLinkId'],
          isShared: data['isShared'] ?? false,
          frontImageUrl: data['frontImageUrl'],
        );
      }).toList();
    } on FirebaseException catch (e) {
      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Failed to get purchased cards'),
        description: Text(_getFirebaseErrorMessage(e.code)),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      throw Exception('Failed to get purchased cards: $e');
    } catch (e) {
      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Failed to get purchased cards'),
        description: Text('An unexpected error occurred'),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      throw Exception('Failed to get purchased cards: $e');
    }
  }

  @override
  Future<List<CardEntity>> getReceivedCards(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('receivedCards')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return CardEntity(
          id: doc.id,
          templateId: data['templateId'],
          senderId: data['senderId'],
          receiverId: data['receiverId'],
          receiverEmail: data['receiverEmail'],
          receiverPhone: data['receiverPhone'],
          toName: data['toName'],
          fromName: data['fromName'],
          greetingMessage: data['greetingMessage'],
          customImageUrl: data['customImageUrl'],
          voiceNoteUrl: data['voiceNoteUrl'],
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          isOpened: data['isOpened'] ?? false,
          creditsAttached: data['creditsAttached'] ?? 0,
          shareLinkId: data['shareLinkId'],
          isShared: data['isShared'] ?? false,
          frontImageUrl: data['frontImageUrl'],
        );
      }).toList();
    } on FirebaseException catch (e) {
      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Failed to get received cards'),
        description: Text(_getFirebaseErrorMessage(e.code)),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      throw Exception('Failed to get received cards: $e');
    } catch (e) {
      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Failed to get received cards'),
        description: Text('An unexpected error occurred'),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      throw Exception('Failed to get received cards: $e');
    }
  }

  @override
  Future<void> updateCard(
      String cardId, String userId, Map<String, dynamic> updates) async {
    try {
      // Try to update in purchasedCards first
      DocumentReference purchasedRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('purchasedCards')
          .doc(cardId);

      DocumentSnapshot purchasedDoc = await purchasedRef.get();

      if (purchasedDoc.exists) {
        await purchasedRef.update(updates);
        return;
      } else {
        throw Exception('Card not found for update');
      }
    } on FirebaseException catch (e) {
      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Failed to update card'),
        description: Text(_getFirebaseErrorMessage(e.code)),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      throw Exception('Failed to update card: $e');
    } catch (e) {
      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Failed to update card'),
        description: Text('An unexpected error occurred'),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      throw Exception('Failed to update card: $e');
    }
  }

  @override
  Future<String> createShareLink(
      String cardId, CardEntity card, String userId) async {
    try {
      // Generate a short unique ID for the share link
      String shareLinkId = _generateShareLinkId(userId);

      // First, get the latest card data from purchasedCards to ensure we have all the updated information
      DocumentSnapshot purchasedCardDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('purchasedCards')
          .doc(cardId)
          .get();

      if (!purchasedCardDoc.exists) {
        throw Exception('Card not found in user\'s purchased cards');
      }

      Map<String, dynamic> latestCardData =
          purchasedCardDoc.data() as Map<String, dynamic>;

      AppLogger.log('Latest card data from DB: $latestCardData',
          tag: 'CardDatasource');

      // Update the card in user's purchasedCards with the shareLinkId and isShared = true
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('purchasedCards')
          .doc(cardId)
          .update({
        'shareLinkId': shareLinkId,
        'isShared': true,
        'sharedAt': FieldValue.serverTimestamp(),
      });

      // Create a document in sharedCards collection with the LATEST complete card data from DB
      await _firestore.collection('sharedCards').doc(shareLinkId).set({
        'cardId': cardId,
        'templateId': latestCardData['templateId'],
        'senderId': latestCardData['senderId'],
        'receiverId': latestCardData['receiverId'],
        'receiverEmail': latestCardData['receiverEmail'],
        'receiverPhone': latestCardData['receiverPhone'],
        'toName': latestCardData['toName'],
        'fromName': latestCardData['fromName'],
        'greetingMessage': latestCardData['greetingMessage'],
        'customImageUrl': latestCardData['customImageUrl'],
        'voiceNoteUrl': latestCardData['voiceNoteUrl'],
        'createdAt': latestCardData['createdAt'],
        'isOpened': latestCardData['isOpened'] ?? false,
        'creditsAttached': latestCardData['creditsAttached'] ?? 0,
        'shareLinkId': shareLinkId,
        'isActive': true,
        'sharedAt': FieldValue.serverTimestamp(),
        'frontImageUrl': latestCardData['frontImageUrl'],
      });

      // Generate Firebase hosting URL that will redirect to app
      final shareUrl = 'https://mycards-c7f33.web.app/card?id=$shareLinkId';
      AppLogger.log('Generated share link: $shareUrl', tag: 'CardDatasource');

      return shareUrl;
    } on FirebaseException catch (e) {
      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Failed to create share link'),
        description: Text(_getFirebaseErrorMessage(e.code)),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      throw Exception('Failed to create share link: $e');
    } catch (e) {
      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Failed to create share link'),
        description: Text('An unexpected error occurred'),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      throw Exception('Failed to create share link: $e');
    }
  }

  @override
  Future<CardEntity?> getSharedCard(String shareLinkId) async {
    try {
      DocumentSnapshot sharedDoc =
          await _firestore.collection('sharedCards').doc(shareLinkId).get();

      if (sharedDoc.exists) {
        Map<String, dynamic> data = sharedDoc.data() as Map<String, dynamic>;
        return CardEntity(
          id: data['cardId'],
          templateId: data['templateId'],
          senderId: data['senderId'],
          receiverId: data['receiverId'],
          receiverEmail: data['receiverEmail'],
          receiverPhone: data['receiverPhone'],
          toName: data['toName'],
          fromName: data['fromName'],
          greetingMessage: data['greetingMessage'],
          customImageUrl: data['customImageUrl'],
          voiceNoteUrl: data['voiceNoteUrl'],
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          isOpened: data['isOpened'] ?? false,
          creditsAttached: data['creditsAttached'] ?? 0,
          shareLinkId: data['shareLinkId'],
          isShared: true,
          frontImageUrl: data['frontImageUrl'],
        );
      }
      return null;
    } on FirebaseException catch (e) {
      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Failed to get shared card'),
        description: Text(_getFirebaseErrorMessage(e.code)),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      throw Exception('Failed to get shared card: $e');
    } catch (e) {
      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Failed to get shared card'),
        description: Text('An unexpected error occurred'),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      throw Exception('Failed to get shared card: $e');
    }
  }

  @override
  Future<void> addToReceivedCards(String shareLinkId, String receiverId) async {
    try {
      // Get the shared card data
      CardEntity? sharedCard = await getSharedCard(shareLinkId);
      if (sharedCard == null) {
        throw Exception('Shared card not found');
      }

      // Don't add to received cards if the receiver is the sender
      if (sharedCard.senderId == receiverId) {
        return;
      }

      // Add to user's receivedCards collection
      await _firestore
          .collection('users')
          .doc(receiverId)
          .collection('receivedCards')
          .doc(sharedCard.id)
          .set({
        'templateId': sharedCard.templateId,
        'senderId': sharedCard.senderId,
        'receiverId': receiverId,
        'receiverEmail': sharedCard.receiverEmail,
        'receiverPhone': sharedCard.receiverPhone,
        'toName': sharedCard.toName,
        'fromName': sharedCard.fromName,
        'greetingMessage': sharedCard.greetingMessage,
        'customImageUrl': sharedCard.customImageUrl,
        'voiceNoteUrl': sharedCard.voiceNoteUrl,
        'createdAt': sharedCard.createdAt,
        'isOpened': false, // New received card
        'creditsAttached': sharedCard.creditsAttached,
        'shareLinkId': sharedCard.shareLinkId,
        'isShared': true,
        'frontImageUrl': sharedCard.frontImageUrl,
      });
    } on FirebaseException catch (e) {
      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Failed to add to received cards'),
        description: Text(_getFirebaseErrorMessage(e.code)),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      throw Exception('Failed to add to received cards: $e');
    } catch (e) {
      // Show error toast
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text('Failed to add to received cards'),
        description: Text('An unexpected error occurred'),
        autoCloseDuration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline),
      );

      throw Exception('Failed to add to received cards: $e');
    }
  }

  String _generateShareLinkId(String userId) {
    // Generate a 6-character alphanumeric ID
    final chars = '${userId}ABCDEFGHIJKLMNOPQRSTUVWXYZ012345678911';
    final random = DateTime.now().millisecondsSinceEpoch;
    String result = '';
    for (int i = 0; i < 6; i++) {
      result += chars[random % chars.length];
    }
    return result;
  }
}

final cardDatasourceProvider = Provider<CardDatasource>((ref) {
  return CardDatasourceImpl();
});
