import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/common/extensions/context_extensions.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const AppBarWidget({super.key, required this.title});

  double _getBorderRadius(BuildContext context) {
    final width = context.width;
    if (width < 360) return 16.0;
    if (width < 400) return 20.0;
    if (width < 600) return 24.0;
    return 28.0;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        constraints: const BoxConstraints(maxHeight: 80),
        decoration: BoxDecoration(
          color: context.colors.primary,
          borderRadius: BorderRadius.circular(_getBorderRadius(context)),
        ),
        child: Text(
          title,
          maxLines: 1,
          softWrap: false,
          textAlign: TextAlign.center,
          overflow: TextOverflow.fade,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: context.responsive(27),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
