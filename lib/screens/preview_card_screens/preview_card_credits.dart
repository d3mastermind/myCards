import 'package:flutter/material.dart';

class PreviewCardCreditsCelebrationScreen extends StatelessWidget {
  const PreviewCardCreditsCelebrationScreen({
    super.key,
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
            const SizedBox(height: 24),
            // Celebration Icon
            const Icon(
              Icons.card_giftcard,
              size: 120,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            // Celebration Message
            Text(
              "🎉 Yaay! You just received 600 Credits! 🎉",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              "These credits are now in your wallet and can be used to unlock premium cards or make exciting purchases in the app. Isn't that awesome?",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Decorative Celebration Animation/Graphics Placeholder
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(70),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: Colors.white,
                    size: 30,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Suprise your receipent and Attach credits to your card to make it even more rewarding!",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Call to Action

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
