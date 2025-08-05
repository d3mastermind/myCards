import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mycards/widgets/skeleton/image_skeleton.dart';

class FrontCoverView extends StatefulWidget {
  const FrontCoverView({
    super.key,
    required this.image,
    this.isUrl = false,
  });

  final String image;
  final bool? isUrl;

  @override
  State<FrontCoverView> createState() => _FrontCoverViewState();
}

class _FrontCoverViewState extends State<FrontCoverView> {
  @override
  Widget build(BuildContext context) {
    return widget.isUrl == true
        ? CachedNetworkImage(
            imageUrl: widget.image,
            fit: BoxFit.fill,
            placeholder: (context, url) => const Center(
              child: ImageSkeletonLoader(
                width: 150,
                height: 500,
                borderRadius: 12,
              ),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          )
        : Image.asset(
            widget.image,
            fit: BoxFit.fill,
          );
  }
}
