import 'package:flutter/material.dart';

class ImageUploadView extends StatefulWidget {
  const ImageUploadView({super.key, required this.customImageUrl});
  final String customImageUrl;

  @override
  State<ImageUploadView> createState() => _ImageUploadViewState();
}

class _ImageUploadViewState extends State<ImageUploadView> {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      widget.customImageUrl,
      fit: BoxFit.cover,
    );
  }
}
