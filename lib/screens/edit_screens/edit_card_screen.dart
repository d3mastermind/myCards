import 'package:flutter/material.dart';
import 'package:mycards/screens/card_screens/custom_text_view.dart';
import 'package:mycards/screens/card_screens/front_cover.dart';
import 'package:mycards/screens/edit_screens/edit_message_screen.dart';
import 'package:mycards/screens/edit_screens/send_card_credits.dart';

class EditCardPage extends StatelessWidget {
  const EditCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
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
                    child: FrontCoverView(image: "assets/images/3.jpg"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: EditMessageView(),
                  ),
                ),
                Placeholder(),
                Placeholder(),
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
