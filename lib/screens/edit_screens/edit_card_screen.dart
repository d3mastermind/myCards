import 'package:flutter/material.dart';
import 'package:mycards/screens/card_screens/custom_text_view.dart';
import 'package:mycards/screens/card_screens/front_cover.dart';
import 'package:mycards/screens/edit_screens/edit_message_screen.dart';
import 'package:mycards/screens/edit_screens/send_card_credits.dart';

class EditCardScreen extends StatefulWidget {
  const EditCardScreen({Key? key}) : super(key: key);

  @override
  _EditCardScreenState createState() => _EditCardScreenState();
}

class _EditCardScreenState extends State<EditCardScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Card'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Tab Pages
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                // First Page: Front Cover
                Center(
                  child: Image.asset(
                    'assets/images/front_cover.png',
                    fit: BoxFit.cover,
                  ),
                ),
                // Second Page: Text Editing
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Edit Text",
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          labelText: "Enter your custom message",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                // Third Page: Upload Custom Image
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Trigger image picker
                        },
                        child: const Text("Upload Custom Image"),
                      ),
                    ],
                  ),
                ),
                // Fourth Page: Voice Note Recording and Playing
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // Trigger voice recording
                        },
                        icon: const Icon(Icons.mic),
                        label: const Text("Record Voice Note"),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Trigger playback
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text("Play Voice Note"),
                      ),
                    ],
                  ),
                ),
                // Fifth Page: Assign Credits
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Assign Credits",
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Enter Credits",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Dot Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _currentPage == index ? Colors.blue : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class MyTabBar extends StatelessWidget {
  const MyTabBar({super.key});

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
                Expanded(child: EditCardScreen()),
                Expanded(child: EditCardScreen()),
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
