import 'package:flutter/material.dart';
import 'package:mycards/screens/edit_screens/edit_card_screen.dart';
import 'package:mycards/screens/pre_edit_card_screens/pre_edit_card_page_view.dart';

class PreEditCardPreviewPage extends StatelessWidget {
  final Map<String, dynamic> template;

  const PreEditCardPreviewPage({super.key, required this.template});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Card Preview",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //const SizedBox(height: 16),

            const SizedBox(height: 8),
            // Card preview using CardPageView
            Expanded(
              child: SizedBox(
                  width: 350,
                  child: PreEditCardPageView(
                    template: template,
                    includeLastPage: false,
                  )),
            ),
            // Bottom section with card name, price, and purchase button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    template["cardName"] ?? "Generic Card Name",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Price: ${template["price"] ?? "50"} credits",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyTabBar(),
                            ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Purchase and Customize",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
