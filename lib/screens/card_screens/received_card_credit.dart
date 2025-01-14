import 'package:flutter/material.dart';

class CardCreditsCelebrationScreen extends StatelessWidget {
  final int receivedCredits;

  const CardCreditsCelebrationScreen({
    super.key,
    required this.receivedCredits,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Surprise! 🎉",
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.orange,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // Celebration Icon
            const Icon(
              Icons.card_giftcard,
              size: 120,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            // Celebration Message
            Text(
              "🎉 Yaay! You just received $receivedCredits Credits! 🎉",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "These credits are now in your wallet and can be used to unlock premium cards or make exciting purchases in the app. Isn't that awesome?",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Decorative Celebration Animation/Graphics Placeholder

            const Spacer(),
            // Call to Action
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: Colors.orange,
              ),
              child: const Text(
                "Explore More Cards",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
