import 'package:mycards/features/cards/domain/card_entity.dart';

class CardModel extends CardEntity {
  CardModel({
    required super.frontImageUrl,
    required super.id,
    required super.templateId,
    super.senderId,
    super.receiverId,
    super.receiverEmail,
    super.receiverPhone,
    super.toName,
    super.fromName,
    super.greetingMessage,
    super.customImageUrl,
    super.voiceNoteUrl,
    required super.createdAt,
    super.isOpened = false,
    super.creditsAttached = 0,
    super.shareLinkId,
    super.isShared = false,
  });

  factory CardModel.fromMap(String id, Map<String, dynamic> data) {
    return CardModel(
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
      createdAt: data['createdAt'],
      isOpened: data['isOpened'],
      creditsAttached: data['creditsAttached'],
      shareLinkId: data['shareLinkId'],
      isShared: data['isShared'] ?? false,
      frontImageUrl: data['frontImageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'templateId': templateId,
      'senderId': senderId,
      'receiverId': receiverId,
      'receiverEmail': receiverEmail,
      'receiverPhone': receiverPhone,
      'toName': toName,
      'fromName': fromName,
      'greetingMessage': greetingMessage,
      'customImageUrl': customImageUrl,
      'voiceNoteUrl': voiceNoteUrl,
      'createdAt': createdAt,
      'isOpened': isOpened,
      'creditsAttached': creditsAttached,
      'shareLinkId': shareLinkId,
      'isShared': isShared,
      'frontImageUrl': frontImageUrl,
    };
  }
}
