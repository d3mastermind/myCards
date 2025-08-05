import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mycards/features/edit_screens/card_data_provider.dart';
import 'package:mycards/features/card_screens/custom_text_view.dart';
import 'package:mycards/features/card_screens/front_cover.dart';
import 'package:mycards/features/card_screens/image_upload_view.dart';
import 'package:mycards/features/card_screens/received_credit.dart';
import 'package:mycards/features/card_screens/share_card_view.dart';
import 'package:mycards/features/card_screens/voice_message_view.dart';
import 'package:mycards/widgets/loading_overlay.dart';
import 'package:mycards/core/utils/logger.dart';
import 'package:mycards/widgets/loading_indicators/circular_loading_widget.dart';

class CardPageView extends ConsumerStatefulWidget {
  const CardPageView({
    super.key,
    required this.cardData,
    this.showSave = true,
  });
  final CardData cardData;
  final bool showSave;

  @override
  ConsumerState<CardPageView> createState() => _CardPageViewState();
}

class _CardPageViewState extends ConsumerState<CardPageView> {
  late final PageController _pageController;
  int _currentPage = 0;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void goToShareScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShareCardView(cardData: widget.cardData),
      ),
    );
  }

  Future<void> saveCard() async {
    AppLogger.log('Starting card save process...', tag: 'CardPageView');
    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      // Save card to repository
      AppLogger.log('Saving card to repository...', tag: 'CardPageView');
      await ref.read(cardEditingProvider.notifier).saveCardToRepository();
      AppLogger.log('Card saved successfully, navigating to share screen',
          tag: 'CardPageView');

      if (!mounted) return;
      goToShareScreen();
    } catch (e) {
      AppLogger.logError('Error saving card: $e', tag: 'CardPageView');
      setState(() => _error = 'Failed to save card. Please try again.');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String frontCoverImageUrl =
        widget.cardData.card?.frontImageUrl ?? "assets/images/defaultImage.jpg";
    final String toMessage = widget.cardData.toName ?? "To Message";
    final String fromMessage = widget.cardData.fromName ?? "From Message";
    final String customMessage =
        widget.cardData.greetingMessage ?? "Main Message";
    final String? customImageUrl = widget.cardData.customImageUrl;
    final String? customAudioUrl = widget.cardData.voiceNoteUrl;
    final int receivedCredits = widget.cardData.creditsAttached;

    final pages = [
      FrontCoverView(
        image: frontCoverImageUrl,
        isUrl: true,
      ),
      CustomTextView(
        toMessage: toMessage,
        fromMeassage: fromMessage,
        customMessage: customMessage,
        bgImageUrl: frontCoverImageUrl,
        isUrl: true,
      ),
      ImageUploadView(
        customImageUrl: customImageUrl ?? "assets/images/defaultImage.jpg",
      ),
      VoiceMessageView(
        audioUrl: customAudioUrl ?? "audio/defaultaudio.mp3",
        bgImageUrl: frontCoverImageUrl,
        isUrl: true,
      ),
      ReceivedCreditsScreen(receivedCredits: receivedCredits)
    ];

    return Stack(
      children: [
        Scaffold(
          floatingActionButton: widget.showSave
              ? FloatingActionButton(
                  onPressed: _isSaving
                      ? null
                      : () {
                          showSaveCardDialog(context, saveCard);
                        },
                  child: _isSaving
                      ? const CircularLoadingWidget(
                          colors: [
                            Colors.white,
                            Colors.white70,
                            Colors.white54,
                            Colors.white38
                          ],
                        )
                      : const Icon(Icons.save),
                )
              : null,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text("Card Preview"),
            centerTitle: true,
            actions: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(
                    Icons.cancel_outlined,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: pages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0.w, vertical: 8.h),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: pages[index],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      width: _currentPage == index ? 16.w : 8.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Colors.orange
                            : Colors.grey.withAlpha(100),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
        if (_isSaving) const LoadingOverlay(message: 'Saving your card...'),
        if (_error != null)
          Positioned(
            bottom: 16.0.h,
            left: 16.0.w,
            right: 16.0.w,
            child: Card(
              color: Colors.red.shade100,
              child: Padding(
                padding: EdgeInsets.all(8.0.w),
                child: Text(
                  _error!,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

Future<void> showSaveCardDialog(
    BuildContext context, VoidCallback onSave) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirm Save'),
        content: Text(
          "Are you sure you want to save this card? You won't be able to edit it after sharing.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              onSave(); // Trigger the save action
            },
            child: Text('Okay, Save'),
          ),
        ],
      );
    },
  );
}
