import 'package:flutter/material.dart';
import 'dart:io';

class ImageUploadView extends StatefulWidget {
  const ImageUploadView({super.key, required this.customImageUrl});
  final String customImageUrl;

  @override
  State<ImageUploadView> createState() => _ImageUploadViewState();
}

class _ImageUploadViewState extends State<ImageUploadView> {
  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(widget.customImageUrl),
      fit: BoxFit.cover,
    );
  }
}
