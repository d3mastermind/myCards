import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Card Data Class
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

  CardData copyWith({
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

// StateNotifier for managing CardData
class CardDataNotifier extends StateNotifier<CardData> {
  CardDataNotifier(super.initialState);

  void updateCredits(int credits) {
    state = state.copyWith(creditsAttached: credits);
  }

  void saveGreeting(String? to, String? from, String? greeting) {
    state = state.copyWith(to: to, from: from, greeting: greeting);
    log('Saving Greeting - To: $to, From: $from, Greeting: $greeting');
  }

  void uploadCustomImage(String imageUrl) {
    state = state.copyWith(customImage: imageUrl);
  }

  void recordVoiceMessage(String recordingUrl) {
    state = state.copyWith(voiceRecording: recordingUrl);
  }
}

final cardEditingProvider = StateNotifierProvider<CardDataNotifier, CardData>(
  (ref) {
    throw UnimplementedError('Provider must be overridden');
  },
);
