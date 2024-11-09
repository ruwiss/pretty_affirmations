import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/common/common.dart';
import 'package:pretty_affirmations/ui/widgets/splash_svg_button.dart';

class ActionButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String svg;
  final bool reversedColor;
  const ActionButton({
    super.key,
    required this.svg,
    this.onTap,
    this.reversedColor = false,
  });

  @override
  Widget build(BuildContext context) {
    return SplashSvgButton(
      onTap: onTap,
      svg: svg,
      svgWidth: 30,
      radius: 25,
      colorFilter: reversedColor
          ? context.colors.surface.withSrcInFilter()
          : context.colors.onSurface.withSrcInFilter(),
    );
  }
}

class ActionButtons extends StatelessWidget {
  final VoidCallback? onLikeTap;
  final VoidCallback? onShareTap;
  final bool reversedColor;
  const ActionButtons({
    super.key,
    this.onLikeTap,
    this.onShareTap,
    this.reversedColor = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 65),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ActionButton(
            svg: AppVectors.like,
            onTap: onLikeTap,
            reversedColor: reversedColor,
          ),
          const Gap(10),
          ActionButton(
            svg: AppVectors.share,
            onTap: onShareTap,
            reversedColor: reversedColor,
          ),
        ],
      ),
    );
  }
}
