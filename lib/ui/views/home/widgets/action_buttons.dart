import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/common/common.dart';
import 'package:pretty_affirmations/ui/widgets/splash_svg_button.dart';

class ActionButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String? svg;
  final IconData? icon;
  final bool reversedColor;
  final Color? color;
  final Color? colorReversed;
  const ActionButton({
    super.key,
    this.svg,
    this.icon,
    this.onTap,
    this.reversedColor = false,
    this.color,
    this.colorReversed,
  });

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return IconButton(
        onPressed: onTap,
        icon: Icon(
          icon,
          size: 30,
          color: reversedColor
              ? colorReversed ?? context.colors.surface
              : color ?? context.colors.onSurface,
        ),
      );
    } else {
      return SplashSvgButton(
        onTap: onTap,
        svg: svg!,
        svgWidth: 30,
        radius: 25,
        colorFilter: reversedColor
            ? colorReversed?.withSrcInFilter() ??
                context.colors.surface.withSrcInFilter()
            : color?.withSrcInFilter() ??
                context.colors.onSurface.withSrcInFilter(),
      );
    }
  }
}

class ActionButtons extends StatelessWidget {
  final VoidCallback? onLikeTap;
  final VoidCallback? onShareTap;
  final VoidCallback? onFirstPageTap;
  final bool reversedColor;
  final bool showFirstPageButton;
  final bool isFavourite;
  const ActionButtons({
    super.key,
    this.onLikeTap,
    this.onShareTap,
    this.onFirstPageTap,
    this.reversedColor = false,
    this.showFirstPageButton = false,
    this.isFavourite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 65),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showFirstPageButton) ...[
            ActionButton(
              icon: Icons.arrow_back_ios_new,
              onTap: onFirstPageTap,
              reversedColor: reversedColor,
            ),
            const Gap(10),
          ],
          ActionButton(
            svg: isFavourite ? AppVectors.liked : AppVectors.like,
            onTap: onLikeTap,
            reversedColor: reversedColor,
            color: isFavourite ? Colors.red : null,
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
