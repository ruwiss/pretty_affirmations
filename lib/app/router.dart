import 'package:flutter/widgets.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/ui/layouts/app_layout.dart';
import 'package:pretty_affirmations/ui/views/favourites/favouries_view.dart';
import 'package:pretty_affirmations/ui/views/favourites/favourites_viewmodel.dart';
import 'package:pretty_affirmations/ui/views/home/home_view.dart';
import 'package:pretty_affirmations/ui/views/home/home_viewmodel.dart';
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

  static final _routerKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    initialLocation: _initialRoute,
    navigatorKey: _routerKey,
    routes: [
      _splashView,
      ShellRoute(
        builder: (context, state, child) {
          return AppLayout(location: state.matchedLocation, child: child);
        },
        routes: [
          _favouritesRoute(),
          _topicsRoute(),
          _homeRoute(),
          _storiesRoute(),
          _settingsRoute(),
        ],
      ),
    ],
  );

  static CustomTransitionPage _customTransitionPage(Widget child) {
    return CustomTransitionPage(
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
        child: child,
      ),
    );
  }

  static final GoRoute _splashView = GoRoute(
    path: splashRoute,
    pageBuilder: (context, state) => _customTransitionPage(
      ChangeNotifierProvider<SplashViewmodel>(
        create: (context) => SplashViewmodel(),
        child: const SplashView(),
      ),
    ),
  );

  static GoRoute _favouritesRoute() {
    return GoRoute(
      path: favouritesRoute,
      pageBuilder: (context, state) => _customTransitionPage(
        ChangeNotifierProvider(
          create: (context) => FavouritesViewmodel(),
          child: FavouriesView(),
        ),
      ),
    );
  }

  static GoRoute _topicsRoute() {
    return GoRoute(
      path: topicsRoute,
      pageBuilder: (context, state) => _customTransitionPage(
        ChangeNotifierProvider<TopicsViewmodel>(
          create: (_) => TopicsViewmodel()..init(context),
          child: const TopicsView(),
        ),
      ),
    );
  }

  static GoRoute _homeRoute() {
    return GoRoute(
      path: homeRoute,
      pageBuilder: (context, state) => _customTransitionPage(
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(),
          child: const HomeView(),
        ),
      ),
    );
  }

  static GoRoute _storiesRoute() {
    return GoRoute(
      path: storiesRoute,
      pageBuilder: (context, state) => _customTransitionPage(
        ChangeNotifierProvider(
          create: (context) => StoriesViewmodel(),
          child: const StoriesView(),
        ),
      ),
    );
  }

  static GoRoute _settingsRoute() {
    return GoRoute(
      path: settingsRoute,
      pageBuilder: (context, state) => _customTransitionPage(
        ChangeNotifierProvider(
          create: (context) => SettingsViewmodel(),
          child: const SettingsView(),
        ),
      ),
    );
  }
}
