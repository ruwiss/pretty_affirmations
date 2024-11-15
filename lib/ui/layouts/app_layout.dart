import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/common/common.dart';
import 'package:pretty_affirmations/ui/widgets/splash_svg_button.dart';

class AppLayout extends StatelessWidget {
  final Widget child;
  final String location;
  const AppLayout({super.key, required this.child, required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
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
            _menuButton(context, svg: AppVectors.likeMenu, route: '/favourites'),
            _menuButton(context, svg: AppVectors.topicsMenu, route: '/topics'),
            _menuButton(context, svg: AppVectors.logo, route: '/home'),
            _menuButton(context, svg: AppVectors.bookMenu, route: '/stories'),
            _menuButton(context, svg: AppVectors.settingsMenu, route: '/settings'),
          ],
        ),
      ),
    );
  }

  Widget _menuButton(BuildContext context, {required String svg, required String route}) {
    final bool isEnabled = location.startsWith(route);
    final bool isHome = route == '/home';
    return SplashSvgButton(
      onTap: () => context.go(route),
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
