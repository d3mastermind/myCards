import 'dart:ui';
import 'dart:developer';

import 'package:flutter/material.dart';

class CustomTextView extends StatefulWidget {
  const CustomTextView({
    super.key,
    required this.toMessage,
    required this.fromMeassage,
    required this.customMessage,
    required this.bgImageUrl,
  });

  final String toMessage;
  final String fromMeassage;
  final String customMessage;
  final String bgImageUrl;

  @override
  State<CustomTextView> createState() => _CustomTextViewState();
}

class _CustomTextViewState extends State<CustomTextView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image with Blur
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(widget.bgImageUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: Container(
                color:
                    Colors.white.withAlpha(200), // Slight overlay for contrast
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
                    child: GestureDetector(
                      onTap: () {
                        log("To message tapped");
                      },
                      child: Text(
                        widget.toMessage,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  // From Message at the Bottom-Right
                  Align(
                    alignment: Alignment.bottomRight,
                    child: GestureDetector(
                      onTap: () {
                        log("From message tapped");
                      },
                      child: Text(
                        widget.fromMeassage,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  // Custom Message at the Center
                  Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () {
                        log("Custom message tapped");
                      },
                      child: Text(
                        widget.customMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
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
