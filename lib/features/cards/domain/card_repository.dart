import 'package:mycards/features/cards/domain/card_entity.dart';

abstract class CardRepository {
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
