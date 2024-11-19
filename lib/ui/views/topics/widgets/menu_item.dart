import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/models/menu_item.dart';

class TopicsMenuItem extends StatelessWidget {
  final MenuItem item;
  final bool skeletonEnabled;
  final bool disabled;
  final VoidCallback? onTap;
  const TopicsMenuItem({
    super.key,
    required this.item,
    this.skeletonEnabled = false,
    this.disabled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      highlightColor: context.colors.tertiary.withOpacity(.2),
      radius: 200,
      child: Ink(
        padding: const EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: switch (item.imageType) {
              MenuItemImageType.asset => AssetImage(item.imageUrl),
              MenuItemImageType.network =>
                CachedNetworkImageProvider(item.imageUrl),
            },
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: _view(context),
      ),
    );
  }

  Align _view(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Text(
        item.name.toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: context.colors.surface,
          fontSize: 19,
        ),
      ),
    );
  }
}
