import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool transparentBg;
  const AppBarWidget({
    super.key,
    required this.title,
    this.transparentBg = false,
  });

  double _getMaxHeight(BuildContext context) =>
      context.width < 400 ? 90.0 : 118.0;

  double _getBorderRadius(BuildContext context) =>
      context.width < 400 ? 20.0 : 24.0;

  EdgeInsets _getPadding(BuildContext context) {
    final statusbarHeight = MediaQuery.of(context).viewPadding.top;
    final horizontalPadding = 0.1.vw;
    return EdgeInsets.only(
      top: statusbarHeight + 12,
      bottom: 12,
      left: horizontalPadding,
      right: horizontalPadding,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: transparentBg ? Colors.transparent : context.colors.surface,
      height: _getMaxHeight(context),
      padding: _getPadding(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: context.colors.primary,
          borderRadius: BorderRadius.circular(_getBorderRadius(context)),
        ),
        child: FittedBox(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}
