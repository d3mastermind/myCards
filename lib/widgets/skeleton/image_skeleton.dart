import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ImageSkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ImageSkeletonLoader({
    super.key,
    this.width = 60,
    this.height = 60,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: shimmerBase,
      highlightColor: shimmerHighlight,
      child: Icon(
        Icons.image,
        size: width,
        color: Colors.grey,
      ),
    );
  }
}


// Hex: #F4F4F4 → RGB: (244, 244, 244)
final Color shimmerBase = Color.fromRGBO(244, 244, 244, 1.0);

// Hex: #FFFFFF → RGB: (255, 255, 255)
final Color shimmerHighlight = Color.fromRGBO(255, 255, 255, 1.0);

