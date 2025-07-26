import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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
          )
        : Image.asset(
            widget.image,
            fit: BoxFit.fill,
          );
  }
}
