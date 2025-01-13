import 'package:flutter/material.dart';

class FrontCoverView extends StatefulWidget {
  const FrontCoverView({
    super.key,
    required this.image,
  });

  final String image;

  @override
  State<FrontCoverView> createState() => _FrontCoverViewState();
}

class _FrontCoverViewState extends State<FrontCoverView> {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      widget.image,
      fit: BoxFit.fill,
    );
  }
}
