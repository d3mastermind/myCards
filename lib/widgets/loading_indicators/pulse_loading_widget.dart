import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class PulseLoadingWidget extends StatelessWidget {
  final List<Color>? colors;
  final double? size;
  final Color? backgroundColor;

  const PulseLoadingWidget({
    super.key,
    this.colors,
    this.size,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size ?? 50.0,
      height: size ?? 50.0,
      child: LoadingIndicator(
        indicatorType: Indicator.ballPulseSync,
        colors: colors ??
            [Colors.red, Colors.orange, Colors.redAccent, Colors.orangeAccent],
        backgroundColor: backgroundColor,
      ),
    );
  }
}
