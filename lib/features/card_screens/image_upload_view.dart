import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:mycards/widgets/loading_indicators/circular_loading_widget.dart';

class ImageUploadView extends StatefulWidget {
  const ImageUploadView({super.key, required this.customImageUrl});
  final String customImageUrl;

  @override
  State<ImageUploadView> createState() => _ImageUploadViewState();
}

class _ImageUploadViewState extends State<ImageUploadView> {
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: widget.customImageUrl,
      placeholder: (context, url) => const Center(
        child: CircularLoadingWidget(),
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }
}
