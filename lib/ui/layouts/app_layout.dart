import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/app/router.dart';
import 'package:pretty_affirmations/common/common.dart';
import 'package:pretty_affirmations/generated/l10n.dart';
import 'package:pretty_affirmations/services/ad_service.dart';
import 'package:pretty_affirmations/services/revenue_cat_service.dart';
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

class _AppLayoutState extends State<AppLayout>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final _adService = AdService();

  late final AnimationController _breathingController;
  late final Animation<double> _slideAnimation;
  late final Animation<Offset> _breathingAnimation;
  late final AnimationController _initialSlideController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _initAds(RevenueCatService().isProUser);

    if (RevenueCatService().isProUser) return;
    // Başlangıç slide animasyonu için controller
    _initialSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // Nefes alma animasyonu için controller
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // İlk giriş animasyonu
    _slideAnimation = Tween<double>(
      begin: -100.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _initialSlideController,
      curve: Curves.easeOutCubic,
    ));

    // Yatay nefes alma animasyonu
    _breathingAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0.2, 0), // Sola doğru hareket miktarı
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _initAds(bool disabled) async {
    _adService
        .init(AdConfig(adIds: kAdIds, testAds: kTestAds, disabled: disabled));
    await _adService.loadAppOpenAd();
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _initialSlideController.dispose();
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
      body: Stack(
        alignment: Alignment.center,
        children: [
          widget.child,
          if (!RevenueCatService().isProUser) _buildRemoveAdsButton(context),
        ],
      ),
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

  Widget _buildRemoveAdsButton(BuildContext context) {
    return AnimatedBuilder(
      animation:
          Listenable.merge([_initialSlideController, _breathingController]),
      builder: (context, child) {
        return Positioned(
          top: 40,
          right: _slideAnimation.value,
          child: SlideTransition(
            position: _breathingAnimation,
            child: InkWell(
              onTap: () => context.push(AppRouter.pricingRoute),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: context.colors.tertiary.withAlpha(230),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: context.colors.primary,
                    )),
                child: Text(
                  S.of(context).removeAds,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    height: 1.2,
                    letterSpacing: .5,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
