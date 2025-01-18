import 'package:flutter/material.dart';
import 'package:mycards/providers/card_data_provider.dart';
import 'package:mycards/screens/card_screens/custom_text_view.dart';
import 'package:mycards/screens/card_screens/front_cover.dart';
import 'package:mycards/screens/card_screens/image_upload_view.dart';
import 'package:mycards/screens/card_screens/received_credit.dart';
import 'package:mycards/screens/card_screens/share_card_view.dart';
import 'package:mycards/screens/card_screens/voice_message_view.dart';

class CardPageView extends StatefulWidget {
  const CardPageView({
    super.key,
    required this.cardData,
  });
  final CardData cardData;

  @override
  State<CardPageView> createState() => _CardPageViewState();
}

class _CardPageViewState extends State<CardPageView> {
  late final PageController _pageController;
  int _currentPage = 0;

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

  @override
  Widget build(BuildContext context) {
    final String frontCoverImageUrl = widget.cardData.frontCover;
    final String toMessage = widget.cardData.to!;
    final String fromMessage = widget.cardData.from!;
    final String customMessage = widget.cardData.greeting!;
    final String? customImageUrl = widget.cardData.customImage;
    final String? customAudioUrl = widget.cardData.voiceRecording;
    final int receivedCredits = widget.cardData.creditsAttached!;

    final pages = [
      FrontCoverView(
        image: frontCoverImageUrl,
      ),
      CustomTextView(
        toMessage: toMessage,
        fromMeassage: fromMessage,
        customMessage: customMessage,
        bgImageUrl: frontCoverImageUrl,
      ),
      ImageUploadView(
        customImageUrl: customImageUrl ?? "assets/images/defaultImage.jpg",
      ),
      VoiceMessageView(
        audioUrl: customAudioUrl ?? "audio/defaultaudio.mp3",
        bgImageUrl: frontCoverImageUrl,
      ),
      ReceivedCreditsScreen(receivedCredits: receivedCredits)
    ];

    return Scaffold(
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: pages[index],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 16 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.orange
                        : Colors.grey.withAlpha(100),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
