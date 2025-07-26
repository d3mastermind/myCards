import 'package:flutter/material.dart';

class PreEdit5thPage extends StatelessWidget {
  const PreEdit5thPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withAlpha(200),
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
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),
            // Decorative Celebration Animation/Graphics Placeholder
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(100),
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
                    "Suprise your Recipient and Attach credits to your card to make it even more rewarding!",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.justify,
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
