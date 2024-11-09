import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const AppBarWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final statusbarHeight = MediaQuery.of(context).viewPadding.top;
    return Container(
      margin: EdgeInsets.only(
          top: statusbarHeight + 15, bottom: 15, left: 60, right: 60),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: context.colors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 26),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
