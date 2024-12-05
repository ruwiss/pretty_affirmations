import 'package:flutter/widgets.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/models/menu_item.dart';
import 'package:pretty_affirmations/ui/layouts/app_layout.dart';
import 'package:pretty_affirmations/ui/views/favourites/favouries_view.dart';
import 'package:pretty_affirmations/ui/views/favourites/favourites_viewmodel.dart';
import 'package:pretty_affirmations/ui/views/home/home_view.dart';
import 'package:pretty_affirmations/ui/views/home/home_viewmodel.dart';
import 'package:pretty_affirmations/ui/views/pricing/pricing_view.dart';
import 'package:pretty_affirmations/ui/views/pricing/pricing_viewmodel.dart';
import 'package:pretty_affirmations/ui/views/settings/settings_view.dart';
import 'package:pretty_affirmations/ui/views/settings/settings_viewmodel.dart';
import 'package:pretty_affirmations/ui/views/splash/splash_view.dart';
import 'package:pretty_affirmations/ui/views/splash/splash_viewmodel.dart';
import 'package:pretty_affirmations/ui/views/stories/stories_view.dart';
import 'package:pretty_affirmations/ui/views/stories/stories_viewmodel.dart';
import 'package:pretty_affirmations/ui/views/topics/topics_view.dart';
import 'package:pretty_affirmations/ui/views/topics/topics_viewmodel.dart';

class AppRouter {
  AppRouter._();

  static String get _initialRoute => splashRoute;
  static const String splashRoute = '/splash';
  static const String homeRoute = '/home';
  static const String favouritesRoute = '/favourites';
  static const String topicsRoute = '/topics';
  static const String storiesRoute = '/stories';
  static const String settingsRoute = '/settings';
  static const String pricingRoute = '/pricing';

  static final routerKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    initialLocation: _initialRoute,
    navigatorKey: routerKey,
    routes: [
      _buildRoute(
        splashRoute,
        (context, extra) => SplashViewmodel(),
        const SplashView(),
      ),
      _buildPricingRoute(),
      ShellRoute(
        builder: (context, state, child) {
          return AppLayout(
            location: state.matchedLocation,
            child: child,
          );
        },
        routes: [
          _buildRoute(
            favouritesRoute,
            (context, extra) => FavouritesViewmodel(),
            const FavouriesView(),
          ),
          _buildRoute(
            topicsRoute,
            (context, extra) => TopicsViewmodel()..init(context),
            const TopicsView(),
          ),
          _buildRoute(
            homeRoute,
            (context, extra) => HomeViewModel(context, extra as MenuItem?),
            const HomeView(),
          ),
          _buildRoute(
            storiesRoute,
            (context, extra) => StoriesViewmodel()..init(context),
            const StoriesView(),
          ),
          _buildRoute(
            settingsRoute,
            (context, extra) => SettingsViewmodel(),
            const SettingsView(),
          ),
        ],
      ),
    ],
  );

  static GoRoute _buildRoute<T extends ChangeNotifier>(
    String path,
    T Function(BuildContext, Object?) createViewModel,
    Widget child,
  ) {
    return GoRoute(
      path: path,
      builder: (context, state) => ChangeNotifierProvider<T>(
        create: (context) => createViewModel(context, state.extra),
        child: child,
      ),
    );
  }

  static GoRoute _buildPricingRoute() {
    return GoRoute(
      path: pricingRoute,
      pageBuilder: (context, state) => CustomTransitionPage(
        child: ChangeNotifierProvider(
          create: (context) => PricingViewModel(),
          child: const PricingView(),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
