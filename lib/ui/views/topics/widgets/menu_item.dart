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
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: switch (item.imageType) {
                  MenuItemImageType.asset => FadeInImage(
                      placeholder:
                          const AssetImage('assets/images/placeholder.jpeg'),
                      image: AssetImage(item.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  MenuItemImageType.network => CachedNetworkImage(
                      imageUrl: item.imageUrl,
                      fit: BoxFit.cover,
                      fadeInDuration: const Duration(milliseconds: 500),
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                },
              ),
            ),
            _view(context),
          ],
        ),
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
