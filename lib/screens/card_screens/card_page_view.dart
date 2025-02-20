import 'package:flutter/material.dart';
import 'package:mycards/providers/card_data_provider.dart';
import 'package:mycards/screens/card_screens/custom_text_view.dart';
import 'package:mycards/screens/card_screens/front_cover.dart';
import 'package:mycards/screens/card_screens/image_upload_view.dart';
import 'package:mycards/screens/card_screens/received_credit.dart';
import 'package:mycards/screens/card_screens/share_card_view.dart';
import 'package:mycards/screens/card_screens/voice_message_view.dart';
import 'package:mycards/widgets/loading_overlay.dart';

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
      MaterialPageRoute(builder: (context) => ShareCardView()),
    );
  }

  Future<void> saveCard() async {
    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      await Future.delayed(const Duration(seconds: 2)); // Simulate saving
      if (!mounted) return;
      goToShareScreen();
    } catch (e) {
      setState(() => _error = 'Failed to save card. Please try again.');
    } finally {
      setState(() => _isSaving = false);
    }
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

    return Stack(
      children: [
        Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: _isSaving
                ? null
                : () {
                    showSaveCardDialog(context, saveCard);
                  },
            child: _isSaving
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : const Icon(Icons.save),
          ),
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text("Card Preview"),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Icon(
                  Icons.cancel_outlined,
                  color: Colors.red,
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
        ),
        if (_isSaving) const LoadingOverlay(message: 'Saving your card...'),
        if (_error != null)
          Positioned(
            bottom: 16.0,
            left: 16.0,
            right: 16.0,
            child: Card(
              color: Colors.red.shade100,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
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
