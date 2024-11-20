import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/common/common.dart';

class QuoteIcon extends StatelessWidget {
  final bool reversedColor;

  const QuoteIcon({
    super.key,
    this.reversedColor = false,
  });

  Color _getIconColor(BuildContext context) {
    return reversedColor ? context.colors.surface : context.colors.onSurface;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: SvgPicture.asset(
        AppVectors.quote,
        colorFilter: _getIconColor(context).withSrcInFilter(),
        width: 60,
      ),
    );
  }
}
