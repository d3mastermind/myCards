import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/providers/card_data_provider.dart';
import 'package:mycards/screens/card_screens/front_cover.dart';
import 'package:mycards/screens/edit_screens/custom_image_screen.dart';
import 'package:mycards/screens/edit_screens/edit_message_screen.dart';
import 'package:mycards/screens/edit_screens/send_card_credits.dart';
import 'package:mycards/screens/edit_screens/voice_recording_screen.dart';

class EditCardPage extends ConsumerWidget {
  const EditCardPage({super.key, required this.template});
  final Map<String, dynamic> template;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Provider for CardData state
    final cardData = ref.watch(cardDataProvider(template));
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        floatingActionButton: IconButton(
            onPressed: () {
              print(cardData.greeting);
            },
            icon: Icon(Icons.print)),
        backgroundColor: Colors.white,
        appBar: AppBar(title: Text("Customise card")),
        body: Column(
          children: [
            TabBar(
              tabs: [
                Tab(
                  child: Icon(Icons.edit_document),
                ),
                Tab(
                  child: Icon(Icons.edit_note_outlined),
                ),
                Tab(
                  child: Icon(Icons.image_outlined),
                ),
                Tab(
                  child: Icon(Icons.mic_outlined),
                ),
                Tab(
                  child: Icon(Icons.monetization_on_outlined),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: FrontCoverView(image: template["frontCover"]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: EditMessageView(
                      bgImage: template["frontCover"],
                      template: template,
                    ),
                  ),
                ),
                CustomImageScreen(),
                VoiceRecordingScreen(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SendCardCreditsScreen(currentBalance: 900),
                  ),
                ),
              ]),
            )
          ],
        ),
      ),
    );
  }
}
