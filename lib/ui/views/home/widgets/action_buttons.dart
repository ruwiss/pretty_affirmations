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
    return icon != null ? _buildIconButton(context) : _buildSvgButton(context);
  }

  Widget _buildIconButton(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        size: 30,
        color: _getColor(context),
      ),
    );
  }

  Widget _buildSvgButton(BuildContext context) {
    return SplashSvgButton(
      onTap: onTap,
      svg: svg!,
      svgWidth: 30,
      radius: 25,
      colorFilter: _getColor(context).withSrcInFilter(),
    );
  }

  Color _getColor(BuildContext context) {
    if (reversedColor) {
      return colorReversed ?? context.colors.surface;
    }
    return color ?? context.colors.onSurface;
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
            _buildFirstPageButton(),
            const Gap(10),
          ],
          _buildLikeButton(),
          const Gap(10),
          _buildShareButton(),
        ],
      ),
    );
  }

  Widget _buildFirstPageButton() {
    return ActionButton(
      icon: Icons.arrow_back_ios_new,
      onTap: onFirstPageTap,
      reversedColor: reversedColor,
    );
  }

  Widget _buildLikeButton() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: ActionButton(
        key: ValueKey<bool>(isFavourite),
        svg: isFavourite ? AppVectors.liked : AppVectors.like,
        onTap: onLikeTap,
        reversedColor: reversedColor,
        color: isFavourite ? Colors.red : null,
      ),
    );
  }

  Widget _buildShareButton() {
    return ActionButton(
      svg: AppVectors.share,
      onTap: onShareTap,
      reversedColor: reversedColor,
    );
  }
}
