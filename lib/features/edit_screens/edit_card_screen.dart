import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mycards/features/edit_screens/card_data_provider.dart';
import 'package:mycards/features/card_screens/front_cover.dart';
import 'package:mycards/features/edit_screens/custom_image_screen.dart';
import 'package:mycards/features/edit_screens/edit_message_screen.dart';
import 'package:mycards/features/edit_screens/send_card_credits.dart';
import 'package:mycards/features/edit_screens/voice_recording_screen.dart';
import 'package:mycards/features/cards/domain/card_entity.dart';
import 'package:mycards/features/app_user/app_user_provider.dart';
import 'package:mycards/features/cards/data/card_repository_impl.dart';
import 'package:mycards/core/utils/logger.dart';

// edit_card_screen.dart
class EditCardPage extends ConsumerStatefulWidget {
  const EditCardPage({super.key, required this.template, this.cardId});
  final Map<String, dynamic> template;
  final String? cardId;

  @override
  ConsumerState<EditCardPage> createState() => _EditCardPageState();
}

class _EditCardPageState extends ConsumerState<EditCardPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    // Initialize card data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCardData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Custom tab builder method
  Widget _buildCustomTab(int index, IconData icon, String label) {
    return Expanded(
      child: AnimatedBuilder(
        animation: _tabController,
        builder: (context, child) {
          final isSelected = _tabController.index == index;
          return GestureDetector(
            onTap: () {
              _tabController.animateTo(index);
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFFFF5722), Color(0xFFFF7043)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : Colors.transparent,
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 20.sp,
                    color: isSelected ? Colors.white : Colors.grey[600],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _initializeCardData() async {
    final cardNotifier = ref.read(cardEditingProvider.notifier);
    final user = AppUserService.instance.currentUser;

    if (user == null) {
      AppLogger.logError('No user available for card editing',
          tag: 'EditCardPage');
      return;
    }

    if (widget.cardId != null) {
      // Load existing card data
      try {
        AppLogger.log('Loading existing card with ID: ${widget.cardId}',
            tag: 'EditCardPage');
        final cardRepository = ref.read(cardRepositoryProvider);
        final existingCard =
            await cardRepository.getCard(widget.cardId!, user.userId);

        if (existingCard != null) {
          AppLogger.log('Found existing card, loading into provider',
              tag: 'EditCardPage');
          cardNotifier.loadCard(existingCard);
        } else {
          AppLogger.log('No existing card found, creating new card',
              tag: 'EditCardPage');
          _createNewCard(cardNotifier, user.userId);
        }
      } catch (e) {
        AppLogger.logError('Error loading existing card: $e',
            tag: 'EditCardPage');
        // Fallback to creating new card
        _createNewCard(cardNotifier, user.userId);
      }
    } else {
      // Create new card from template
      AppLogger.log('Creating new card from template', tag: 'EditCardPage');
      _createNewCard(cardNotifier, user.userId);
    }
  }

  void _createNewCard(CardDataNotifier cardNotifier, String userId) {
    // Create initial card entity from template
    final initialCard = CardEntity(
      id: widget.cardId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      templateId: widget.template["templateId"],
      senderId: userId,
      frontImageUrl: widget.template["frontCover"],
      createdAt: DateTime.now(),
      isShared: false,
      creditsAttached: 0,
    );

    // Load the card into the provider
    cardNotifier.loadCard(initialCard);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _saveCard();
          ref.read(cardEditingProvider.notifier).clearCard();
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFF8E1), // Light orange background
                Colors.white,
              ],
            ),
          ),
          child: Column(
            children: [
              // Custom App Bar
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF5722), Color(0xFFFF7043)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12.h),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios,
                              color: Colors.white),
                        ),
                        Expanded(
                          child: Text(
                            widget.cardId != null
                                ? "Edit Card"
                                : "Customise Card",
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.save, color: Colors.white),
                            onPressed: _saveCard,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Custom Tab Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Row(
                    children: [
                      _buildCustomTab(0, Icons.edit_document, 'Front'),
                      SizedBox(width: 8.w),
                      _buildCustomTab(1, Icons.edit_note_outlined, 'Message'),
                      SizedBox(width: 8.w),
                      _buildCustomTab(2, Icons.image_outlined, 'Image'),
                      SizedBox(width: 8.w),
                      _buildCustomTab(3, Icons.mic_outlined, 'Voice'),
                      SizedBox(width: 8.w),
                      _buildCustomTab(
                          4, Icons.monetization_on_outlined, 'Credits'),
                    ],
                  ),
                ),
              ),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Front Cover Tab
                    Container(
                      margin: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: FrontCoverView(
                          image: widget.template["frontCover"],
                          isUrl: true,
                        ),
                      ),
                    ),

                    // Message Tab
                    Container(
                      margin: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: EditMessageView(
                          bgImage: widget.template["frontCover"],
                        ),
                      ),
                    ),

                    // Image Tab
                    Container(
                      margin: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: CustomImageScreen(),
                      ),
                    ),

                    // Voice Tab
                    Container(
                      margin: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: VoiceRecordingScreen(),
                      ),
                    ),

                    // Credits Tab
                    Container(
                      margin: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: SendCardCreditsScreen(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveCard() async {
    try {
      final cardNotifier = ref.read(cardEditingProvider.notifier);
      final user = AppUserService.instance.currentUser;

      if (user == null) {
        AppLogger.logError('No user available for saving card',
            tag: 'EditCardPage');
        return;
      }

      if (widget.cardId != null) {
        // Update existing card
        AppLogger.log('Updating existing card: ${widget.cardId}',
            tag: 'EditCardPage');
        await cardNotifier.updateCardInRepository(widget.cardId!);
      } else {
        // Save new card to repository
        AppLogger.log('Saving new card to repository', tag: 'EditCardPage');
        await cardNotifier.saveCardToRepository();
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    widget.cardId != null
                        ? 'Card updated successfully!'
                        : 'Card saved successfully!',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
      }

      // Log data to debug
      final cardData = ref.read(cardEditingProvider);
      AppLogger.log('To: ${cardData.toName}', tag: 'EditCardPage');
      AppLogger.log('From: ${cardData.fromName}', tag: 'EditCardPage');
      AppLogger.log('Greeting: ${cardData.greetingMessage}',
          tag: 'EditCardPage');
      AppLogger.log('Custom Image: ${cardData.customImageUrl}',
          tag: 'EditCardPage');
      AppLogger.log('Voice Recording: ${cardData.voiceNoteUrl}',
          tag: 'EditCardPage');
      AppLogger.log('Credits: ${cardData.creditsAttached}',
          tag: 'EditCardPage');
    } catch (e) {
      AppLogger.logError('Error saving card: $e', tag: 'EditCardPage');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white, size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Error saving card: $e',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
      }
    }
  }
}
