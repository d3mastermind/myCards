import 'dart:ui';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mycards/widgets/loading_indicators/circular_loading_widget.dart';

class CustomTextView extends StatefulWidget {
  const CustomTextView({
    super.key,
    required this.toMessage,
    required this.fromMeassage,
    required this.customMessage,
    required this.bgImageUrl,
    this.isUrl = false,
  });

  final String toMessage;
  final String fromMeassage;
  final String customMessage;
  final String bgImageUrl;
  final bool isUrl;

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
          if (widget.isUrl)
            // Network Image with CachedNetworkImage
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: widget.bgImageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: CircularLoadingWidget(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Failed to load image',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      colorFilter: ColorFilter.mode(
                        Colors.grey,
                        BlendMode.saturation,
                      ),
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: Container(
                      color: Colors.white.withAlpha(200),
                    ),
                  ),
                ),
              ),
            )
          else
            // Local Asset Image
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
                  color: Colors.white.withAlpha(200),
                ),
              ),
            ),

          // Foreground Content - Natural Handwritten Style
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Stack(
                children: [
                  // To Message at the Top-Left - Handwritten style
                  Align(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                      onTap: () {
                        log("To message tapped");
                      },
                      child: Text(
                        widget.toMessage,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          height: 1.3,
                          shadows: [
                            Shadow(
                              offset: const Offset(1, 1),
                              blurRadius: 2,
                              color: Colors.black.withOpacity(0.1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // From Message at the Bottom-Right - Handwritten style
                  Align(
                    alignment: Alignment.bottomRight,
                    child: GestureDetector(
                      onTap: () {
                        log("From message tapped");
                      },
                      child: Text(
                        widget.fromMeassage,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          height: 1.3,
                          shadows: [
                            Shadow(
                              offset: const Offset(1, 1),
                              blurRadius: 2,
                              color: Colors.black.withOpacity(0.1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Main Custom Message at the Center - Handwritten style
                  Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () {
                        log("Custom message tapped");
                      },
                      child: Container(
                        constraints: const BoxConstraints(
                          maxWidth: 300,
                        ),
                        child: Text(
                          widget.customMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            fontFamily: 'Cursive',
                            height: 1.4,
                            letterSpacing: 0.3,
                            shadows: [
                              Shadow(
                                offset: const Offset(1, 1),
                                blurRadius: 3,
                                color: Colors.black.withOpacity(0.15),
                              ),
                              Shadow(
                                offset: const Offset(0, 1),
                                blurRadius: 1,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ],
                          ),
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
