import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';

class ResponsiveText extends StatelessWidget {
  final String text;
  final bool reversedColor;
  const ResponsiveText(
      {super.key, required this.text, this.reversedColor = false});

  double getFontSize() {
    return switch (text.length) {
      (< 100) => 36.0,
      (< 150) => 32.0,
      (< 200) => 28.0,
      (< 255) => 26.0,
      (< 320) => 24.0,
      (< 380) => 22.0,
      (< 450) => 20.0,
      (< 510) => 19.0,
      (_) => 16
    };
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: getFontSize(),
        color: reversedColor ? context.colors.surface : null,
      ),
    );
  }
}
