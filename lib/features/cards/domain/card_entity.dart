class CardEntity {
  final String id; // Firestore doc ID
  final String templateId; // Reference to base template
  final String? senderId;
  final String? receiverId; // May be null initially (if sent via link)
  final String? receiverEmail; // Optional for identifying pre-signup
  final String? receiverPhone; // Optional
  final String? toName;
  final String? fromName;
  final String? greetingMessage;
  final String? customImageUrl;
  final String frontImageUrl;
  final String? voiceNoteUrl;
  final DateTime createdAt;
  final bool isOpened;
  final int creditsAttached;
  final bool isShared;
  final String? shareLinkId; // Short unique ID used in the shareable URL

  CardEntity({
    required this.id,
    required this.templateId,
    this.senderId,
    this.receiverId,
    this.receiverEmail,
    this.receiverPhone,
    this.toName,
    this.fromName,
    this.greetingMessage,
    this.customImageUrl,
    this.voiceNoteUrl,
    required this.createdAt,
    this.isOpened = false,
    this.creditsAttached = 0,
    this.isShared = false,
    this.shareLinkId,
    required this.frontImageUrl,
  });
}
