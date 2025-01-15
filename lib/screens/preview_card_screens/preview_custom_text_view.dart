import 'dart:ui';
import 'dart:developer';

import 'package:flutter/material.dart';

class PreviewCustomTextView extends StatelessWidget {
  const PreviewCustomTextView({
    super.key,
    required this.bgImageUrl,
  });

  final String bgImageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image with Blur
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(bgImageUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: Container(
                color:
                    Colors.white.withAlpha(200), // Overlay for better contrast
              ),
            ),
          ),

          // Foreground Content
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                children: [
                  // To Message at the Top-Left
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "To: Receiver Name Here",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  // From Message at the Bottom-Right
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      "From: Sender Name Here",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  // Custom Message at the Center
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Your Custom Message Here\nYour Custom Message Here\nYour Custom Message Here\nYour Custom Message Here\nYour Custom Message Here",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            log("Edit message tapped");
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text("Customize Your Message"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
