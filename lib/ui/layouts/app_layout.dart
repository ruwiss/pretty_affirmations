import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/common/common.dart';
import 'package:pretty_affirmations/ui/widgets/splash_svg_button.dart';

class AppLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const AppLayout({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          boxShadow: [
            BoxShadow(
              color: context.colors.primary.withOpacity(.06),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _menuButton(context, svg: AppVectors.likeMenu, index: 0),
            _menuButton(context, svg: AppVectors.topicsMenu, index: 1),
            _menuButton(context, svg: AppVectors.logo, index: 2),
            _menuButton(context, svg: AppVectors.bookMenu, index: 3),
            _menuButton(context, svg: AppVectors.settingsMenu, index: 4),
          ],
        ),
      ),
    );
  }

  Widget _menuButton(BuildContext context,
      {required String svg, required int index}) {
    final bool isEnabled = navigationShell.currentIndex == index;
    final bool isHome = index == 2;
    return SplashSvgButton(
      onTap: () => navigationShell.goBranch(index, initialLocation: isEnabled),
      svg: svg,
      svgWidth: 40,
      radius: isEnabled ? 0 : 30,
      colorFilter: isEnabled
          ? context.colors.onSurface.withSrcInFilter()
          : context.colors.primaryFixed.withSrcInFilter(),
      builder: (context, child) => AnimatedScale(
        scale: isEnabled
            ? isHome
                ? 1.3
                : .9
            : isHome
                ? 1.1
                : .7,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: child,
      ),
    );
  }
}
