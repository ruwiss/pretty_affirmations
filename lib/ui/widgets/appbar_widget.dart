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

  @override
  Widget build(BuildContext context) {
    final statusbarHeight = MediaQuery.of(context).viewPadding.top;
    return Container(
      color: transparentBg ? Colors.transparent : context.colors.surface,
      constraints: const BoxConstraints(maxHeight: 115),
      padding: EdgeInsets.only(
          top: statusbarHeight + 15, bottom: 15, left: 60, right: 60),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: context.colors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: FittedBox(
          child: Text(title, textAlign: TextAlign.center),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
