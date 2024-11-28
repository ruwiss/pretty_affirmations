import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/app/router.dart';
import 'package:pretty_affirmations/common/common.dart';
import 'package:pretty_affirmations/services/ad_service.dart';
import 'package:pretty_affirmations/ui/widgets/splash_svg_button.dart';

class AppLayout extends StatefulWidget {
  final Widget child;
  final String location;
  const AppLayout({
    super.key,
    required this.child,
    required this.location,
  });

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> with WidgetsBindingObserver {
  final _adService = AdService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initAds();
  }

  Future<void> _initAds() async {
    _adService.init(AdConfig(adIds: kAdIds));
    await _adService.loadAppOpenAd();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _adService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _adService.handleAppStateChange(state);
    if (state == AppLifecycleState.resumed) {
      _adService.showAppOpenAd();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
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
        children: _buildNavigationButtons(context),
      ),
    );
  }

  List<Widget> _buildNavigationButtons(BuildContext context) {
    final navigationItems = [
      (svg: AppVectors.likeMenu, route: '/favourites'),
      (svg: AppVectors.topicsMenu, route: '/topics'),
      (svg: AppVectors.logo, route: '/home'),
      (svg: AppVectors.bookMenu, route: '/stories'),
      (svg: AppVectors.settingsMenu, route: '/settings'),
    ];

    return navigationItems
        .map((item) => _buildNavigationButton(
              context,
              svg: item.svg,
              route: item.route,
            ))
        .toList();
  }

  Widget _buildNavigationButton(
    BuildContext context, {
    required String svg,
    required String route,
  }) {
    final bool isEnabled = widget.location.startsWith(route);
    final bool isHome = route == AppRouter.homeRoute;

    return SplashSvgButton(
      onTap: () => context.go(route),
      svg: svg,
      svgWidth: 36,
      radius: isEnabled ? 0 : 28,
      colorFilter: isEnabled
          ? context.colors.onSurface.withSrcInFilter()
          : context.colors.primaryFixed.withSrcInFilter(),
      builder: (context, child) => AnimatedScale(
        scale: _calculateButtonScale(isEnabled, isHome),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: child,
      ),
    );
  }

  double _calculateButtonScale(bool isEnabled, bool isHome) {
    if (isEnabled) {
      return isHome ? 1.3 : 0.85;
    }
    return isHome ? 1.0 : 0.65;
  }
}
