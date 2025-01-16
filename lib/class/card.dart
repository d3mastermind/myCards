class CardData {
  String templateId;
  String frontCover;
  String senderId;
  String? receiverId;
  int? creditsAttached;
  bool isClaimed;
  String? to;
  String? from;
  String? greeting;
  String? customImage;
  String? voiceRecording;

  CardData({
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
  });

  CardData copyWith(Map<String, dynamic> map, {
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
  }) {
    return CardData(
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
    );
  }
}