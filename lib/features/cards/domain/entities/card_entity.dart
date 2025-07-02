import 'package:equatable/equatable.dart';

class CardEntity extends Equatable {
  final String? cardId;
  final String templateId;
  final String frontCover;
  final String senderId;
  final String? receiverId;
  final int? creditsAttached;
  final bool isClaimed;
  final String? to;
  final String? from;
  final String? greeting;
  final String? customImage;
  final String? voiceRecording;
  final DateTime? createdAt;

  const CardEntity({
    this.cardId,
    required this.templateId,
    required this.frontCover,
    required this.senderId,
    this.receiverId,
    this.creditsAttached,
    this.isClaimed = false,
    this.to,
    this.from,
    this.greeting,
    this.customImage,
    this.voiceRecording,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        cardId,
        templateId,
        frontCover,
        senderId,
        receiverId,
        creditsAttached,
        isClaimed,
        to,
        from,
        greeting,
        customImage,
        voiceRecording,
        createdAt,
      ];

  CardEntity copyWith({
    String? cardId,
    String? templateId,
    String? frontCover,
    String? senderId,
    String? receiverId,
    int? creditsAttached,
    bool? isClaimed,
    String? to,
    String? from,
    String? greeting,
    String? customImage,
    String? voiceRecording,
    DateTime? createdAt,
  }) {
    return CardEntity(
      cardId: cardId ?? this.cardId,
      templateId: templateId ?? this.templateId,
      frontCover: frontCover ?? this.frontCover,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      creditsAttached: creditsAttached ?? this.creditsAttached,
      isClaimed: isClaimed ?? this.isClaimed,
      to: to ?? this.to,
      from: from ?? this.from,
      greeting: greeting ?? this.greeting,
      customImage: customImage ?? this.customImage,
      voiceRecording: voiceRecording ?? this.voiceRecording,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
