import 'package:mycards/features/cards/domain/card_entity.dart';
import 'package:mycards/features/cards/domain/card_repository.dart';
import 'package:mycards/features/cards/data/card_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CardRepositoryImpl implements CardRepository {
  final CardDatasource _cardDatasource;

  CardRepositoryImpl(this._cardDatasource);

  @override
  Future<void> createCard(CardEntity card, String userId) async {
    try {
      await _cardDatasource.createCard(card, userId);
    } catch (e) {
      throw Exception('Failed to create card in repository: $e');
    }
  }

  @override
  Future<void> updateCard(
      String cardId, String userId, Map<String, dynamic> updates) async {
    try {
      await _cardDatasource.updateCard(cardId, userId, updates);
    } catch (e) {
      throw Exception('Failed to update card in repository: $e');
    }
  }

  @override
  Future<CardEntity> getCard(String id, String userId) async {
    try {
      return await _cardDatasource.getCard(id, userId);
    } catch (e) {
      throw Exception('Failed to get card in repository: $e');
    }
  }

  @override
  Future<List<CardEntity>> getPurchasedCards(String userId) async {
    try {
      return await _cardDatasource.getPurchasedCards(userId);
    } catch (e) {
      throw Exception('Failed to get purchased cards in repository: $e');
    }
  }

  @override
  Future<List<CardEntity>> getReceivedCards(String userId) async {
    try {
      return await _cardDatasource.getReceivedCards(userId);
    } catch (e) {
      throw Exception('Failed to get received cards in repository: $e');
    }
  }

  @override
  Future<String> createShareLink(
      String cardId, CardEntity card, String userId) async {
    try {
      return await _cardDatasource.createShareLink(cardId, card, userId);
    } catch (e) {
      throw Exception('Failed to create share link in repository: $e');
    }
  }

  @override
  Future<CardEntity?> getSharedCard(String shareLinkId) async {
    try {
      return await _cardDatasource.getSharedCard(shareLinkId);
    } catch (e) {
      throw Exception('Failed to get shared card in repository: $e');
    }
  }

  @override
  Future<void> addToReceivedCards(String shareLinkId, String receiverId) async {
    try {
      await _cardDatasource.addToReceivedCards(shareLinkId, receiverId);
    } catch (e) {
      throw Exception('Failed to add to received cards in repository: $e');
    }
  }
}

// Provider for the card repository
final cardRepositoryProvider = Provider<CardRepository>((ref) {
  return CardRepositoryImpl(CardDatasourceImpl());
});
