import 'package:flutter/material.dart';

class PreviewImageUploadView extends StatelessWidget {
  const PreviewImageUploadView({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Default image asset
        Image.asset(
          'assets/images/defaultImage.jpg', // Path to your default image
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        // Overlay with "Upload Custom Image" text and an edit icon
        Positioned(
          bottom: 100,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(100),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 30,
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload Custom Image',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
