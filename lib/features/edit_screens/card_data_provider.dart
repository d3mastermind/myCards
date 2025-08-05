import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/features/app_user/app_user_provider.dart';
import 'package:mycards/features/auth/domain/entities/user_entity.dart';
import 'package:mycards/features/cards/data/card_datasource.dart';
import 'package:mycards/features/cards/data/card_repository_impl.dart';
import 'package:mycards/features/cards/domain/card_entity.dart';
import 'package:mycards/features/cards/domain/card_repository.dart';

// Card Data Class
class CardData {
  final CardEntity? card;
  final String? toName;
  final String? fromName;
  final String? greetingMessage;
  final String? customImageUrl;
  final String? voiceNoteUrl;
  final int creditsAttached;
  final bool isLoading;

  CardData({
    this.card,
    this.toName,
    this.fromName,
    this.greetingMessage,
    this.customImageUrl,
    this.voiceNoteUrl,
    this.creditsAttached = 0,
    this.isLoading = false,
  });

  CardData copyWith({
    CardEntity? card,
    String? toName,
    String? fromName,
    String? greetingMessage,
    String? customImageUrl,
    String? voiceNoteUrl,
    int? creditsAttached,
    bool? isLoading,
  }) {
    return CardData(
      card: card ?? this.card,
      toName: toName ?? this.toName,
      fromName: fromName ?? this.fromName,
      greetingMessage: greetingMessage ?? this.greetingMessage,
      customImageUrl: customImageUrl ?? this.customImageUrl,
      voiceNoteUrl: voiceNoteUrl ?? this.voiceNoteUrl,
      creditsAttached: creditsAttached ?? this.creditsAttached,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// StateNotifier for managing CardData
class CardDataNotifier extends StateNotifier<CardData> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final CardRepository _cardRepository;
  final UserEntity? _user;

  CardDataNotifier(this._cardRepository, this._user) : super(CardData());

  void updateCredits(int credits) {
    state = state.copyWith(creditsAttached: credits);
  }

  void saveGreeting(String? to, String? from, String? greeting) {
    state = state.copyWith(
      toName: to,
      fromName: from,
      greetingMessage: greeting,
    );
    log('Saving Greeting - To: $to, From: $from, Greeting: $greeting');
  }

  Future<void> uploadCustomImage(File image) async {
    try {
      state = state.copyWith(isLoading: true);

      // Generate unique filename
      final fileName =
          'custom_images/${_user?.userId}/${image.path.split('/').last}';

      // Upload to Firebase Storage
      final storageRef = _storage.ref().child(fileName);
      final uploadTask = storageRef.putFile(image);
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Update state with the download URL
      state = state.copyWith(
        customImageUrl: downloadUrl,
        isLoading: false,
      );

      log('Custom image uploaded successfully: $downloadUrl');
    } catch (e) {
      state = state.copyWith(isLoading: false);
      log('Error uploading custom image: $e');
      throw Exception('Failed to upload custom image: $e');
    }
  }

  Future<void> uploadVoiceMessage(File recording) async {
    try {
      state = state.copyWith(isLoading: true);

      // Generate unique filename
      final fileName =
          'voice_messages/${DateTime.now().millisecondsSinceEpoch}_${recording.path.split('/').last}';

      // Upload to Firebase Storage
      final storageRef = _storage.ref().child(fileName);
      final uploadTask = storageRef.putFile(recording);
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Update state with the download URL
      state = state.copyWith(
        voiceNoteUrl: downloadUrl,
        isLoading: false,
      );

      log('Voice message uploaded successfully: $downloadUrl');
    } catch (e) {
      state = state.copyWith(isLoading: false);
      log('Error uploading voice message: $e');
      throw Exception('Failed to upload voice message: $e');
    }
  }

  Future<void> saveCardToRepository() async {
    try {
      if (state.card == null) {
        throw Exception('No card to save');
      }

      // Create updated card with current state data
      final updatedCard = CardEntity(
        id: state.card!.id,
        templateId: state.card!.templateId,
        senderId: state.card!.senderId,
        receiverId: state.card!.receiverId,
        receiverEmail: state.card!.receiverEmail,
        receiverPhone: state.card!.receiverPhone,
        toName: state.toName ?? state.card!.toName,
        fromName: state.fromName ?? state.card!.fromName,
        greetingMessage: state.greetingMessage ?? state.card!.greetingMessage,
        customImageUrl: state.customImageUrl ?? state.card!.customImageUrl,
        voiceNoteUrl: state.voiceNoteUrl ?? state.card!.voiceNoteUrl,
        createdAt: state.card!.createdAt,
        isOpened: state.card!.isOpened,
        creditsAttached: state.creditsAttached,
        shareLinkId: state.card!.shareLinkId,
        isShared: state.card!.isShared,
        frontImageUrl: state.card!.frontImageUrl,
      );

      // Save to repository
      await _cardRepository.createCard(updatedCard, _user!.userId);

      log('Card saved to repository successfully');
    } catch (e) {
      log('Error saving card to repository: $e');
      throw Exception('Failed to save card: $e');
    }
  }

  Future<void> updateCardInRepository(String cardId) async {
    try {
      final updates = <String, dynamic>{};

      if (state.toName != null) updates['toName'] = state.toName;
      if (state.fromName != null) updates['fromName'] = state.fromName;
      if (state.greetingMessage != null)
        updates['greetingMessage'] = state.greetingMessage;
      if (state.customImageUrl != null)
        updates['customImageUrl'] = state.customImageUrl;
      if (state.voiceNoteUrl != null)
        updates['voiceNoteUrl'] = state.voiceNoteUrl;
      if (state.creditsAttached > 0)
        updates['creditsAttached'] = state.creditsAttached;

      if (updates.isNotEmpty) {
        await _cardRepository.updateCard(cardId, _user!.userId, updates);
        log('Card updated in repository successfully');
      }
    } catch (e) {
      log('Error updating card in repository: $e');
      throw Exception('Failed to update card: $e');
    }
  }

  void loadCard(CardEntity card) {
    state = state.copyWith(
      card: card,
      toName: card.toName,
      fromName: card.fromName,
      greetingMessage: card.greetingMessage,
      customImageUrl: card.customImageUrl,
      voiceNoteUrl: card.voiceNoteUrl,
      creditsAttached: card.creditsAttached,
    );
  }

  void clearCard() {
    state = CardData();
  }
}

final cardEditingProvider = StateNotifierProvider<CardDataNotifier, CardData>(
  (ref) {
    final cardRepository = ref.read(cardRepositoryProvider);
    final user = AppUserService.instance.currentUser;
    return CardDataNotifier(cardRepository, user);
  },
);
