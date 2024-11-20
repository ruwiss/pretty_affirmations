import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';

class ResponsiveText extends StatelessWidget {
  final String text;
  final bool reversedColor;
  const ResponsiveText(
      {super.key, required this.text, this.reversedColor = false});

  double getFontSize(BuildContext context) {
    final isSmallScreen = context.width < 400;
    return switch (text.length) {
      (< 100) => isSmallScreen ? 32.0 : 36.0,
      (< 150) => isSmallScreen ? 28.0 : 32.0,
      (< 200) => isSmallScreen ? 24.0 : 28.0,
      (< 255) => isSmallScreen ? 22.0 : 26.0,
      (< 320) => isSmallScreen ? 20.0 : 24.0,
      (< 380) => isSmallScreen ? 18.0 : 22.0,
      (< 450) => isSmallScreen ? 16.0 : 20.0,
      (< 510) => isSmallScreen ? 15.0 : 19.0,
      (_) => isSmallScreen ? 14.0 : 16.0
    };
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: getFontSize(context),
        color: reversedColor ? context.colors.surface : null,
      ),
    );
  }
}
