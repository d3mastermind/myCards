import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/providers/card_data_provider.dart';
import 'package:mycards/screens/card_screens/front_cover.dart';
import 'package:mycards/screens/edit_screens/custom_image_screen.dart';
import 'package:mycards/screens/edit_screens/edit_message_screen.dart';
import 'package:mycards/screens/edit_screens/send_card_credits.dart';
import 'package:mycards/screens/edit_screens/voice_recording_screen.dart';

// edit_card_screen.dart
class EditCardPage extends ConsumerStatefulWidget {
  const EditCardPage({super.key, required this.template});
  final Map<String, dynamic> template;

  @override
  ConsumerState<EditCardPage> createState() => _EditCardPageState();
}

class _EditCardPageState extends ConsumerState<EditCardPage> {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        cardEditingProvider.overrideWith(
          (ref) => CardDataNotifier(
            CardData(
              templateId: widget.template["templateId"],
              frontCover: widget.template["frontCover"],
              senderId: "currentUserId",
            ),
          ),
        ),
      ],
      child: DefaultTabController(
        length: 5,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text("Customise card"),
            actions: [
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: () => _saveCard(),
              ),
            ],
          ),
          body: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.edit_document)),
                  Tab(icon: Icon(Icons.edit_note_outlined)),
                  Tab(icon: Icon(Icons.image_outlined)),
                  Tab(icon: Icon(Icons.mic_outlined)),
                  Tab(icon: Icon(Icons.monetization_on_outlined)),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: FrontCoverView(
                            image: widget.template["frontCover"]),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: EditMessageView(
                          bgImage: widget.template["frontCover"],
                          provider: cardEditingProvider,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CustomImageScreen(provider: cardEditingProvider),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child:
                            VoiceRecordingScreen(provider: cardEditingProvider),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SendCardCreditsScreen(
                          provider: cardEditingProvider,
                          currentBalance: 900,
                        ),
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
    final cardData = ref.read(cardEditingProvider);
    // Save to Firebase
    log(cardData.greeting!);
  }
}
