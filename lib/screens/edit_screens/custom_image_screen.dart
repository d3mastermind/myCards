import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mycards/providers/card_data_provider.dart';

class CustomImageScreen extends ConsumerWidget {
  const CustomImageScreen({super.key});

  Future<void> pickImage(BuildContext context, WidgetRef ref) async {
    final ImagePicker picker = ImagePicker();

    // Pick an image from the gallery
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Update the provider with the image path
      ref.read(cardEditingProvider.notifier).uploadCustomImage(image.path);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagePath = ref.watch(cardEditingProvider).customImage;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Display the uploaded image or a placeholder
          if (imagePath != null)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: FileImage(File(imagePath)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          else
            GestureDetector(
              onTap: () => pickImage(context, ref),
              child: Container(
                height: 300,
                width: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.upload_file_outlined,
                        size: 100,
                        color: Colors.orange,
                      ),
                      Text(
                        'Tap to Upload Image',
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
          if (imagePath != null)
            ElevatedButton(
              onPressed: () => pickImage(context, ref),
              child: const Text(
                'Change Image',
                style: TextStyle(
                  color: Colors.orange,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
