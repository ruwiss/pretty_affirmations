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
  static final _homeKey = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
  static final _favouritesKey =
      GlobalKey<NavigatorState>(debugLabel: 'shellFavourites');
  static final _topicsKey =
      GlobalKey<NavigatorState>(debugLabel: 'shellTopics');
  static final _storiesKey =
      GlobalKey<NavigatorState>(debugLabel: 'shellStories');
  static final _settingsKey =
      GlobalKey<NavigatorState>(debugLabel: 'shellSettings');

  static final GoRouter router = GoRouter(
    initialLocation: _initialRoute,
    navigatorKey: _routerKey,
    routes: [
      _splashView,
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppLayout(navigationShell: navigationShell);
        },
        branches: [
          _favouritesBranch(),
          _topicsBranch(),
          _homeBranch(),
          _storiesBranch(),
          _settingsBranch(),
        ],
      ),
    ],
  );

  static final GoRoute _splashView = GoRoute(
    path: splashRoute,
    pageBuilder: (context, state) => CustomTransitionPage(
      key: state.pageKey,
      child: ChangeNotifierProvider<SplashViewmodel>(
        create: (context) => SplashViewmodel(),
        child: const SplashView(),
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
        child: child,
      ),
    ),
  );

  static StatefulShellBranch _favouritesBranch() {
    return StatefulShellBranch(
      navigatorKey: _favouritesKey,
      routes: [
        GoRoute(
          path: favouritesRoute,
          builder: (context, state) => ChangeNotifierProvider(
            create: (_) => FavouritesViewmodel(),
            child: FavouriesView(),
          ),
        )
      ],
    );
  }

  static StatefulShellBranch _topicsBranch() {
    return StatefulShellBranch(
      navigatorKey: _topicsKey,
      routes: [
        GoRoute(
          path: topicsRoute,
          builder: (context, state) => ChangeNotifierProvider(
            create: (_) => TopicsViewmodel(),
            child: const TopicsView(),
          ),
        )
      ],
    );
  }

  static StatefulShellBranch _homeBranch() {
    return StatefulShellBranch(
      navigatorKey: _homeKey,
      routes: [
        GoRoute(
          path: homeRoute,
          builder: (context, state) => ChangeNotifierProvider(
            create: (_) => HomeViewModel(),
            child: const HomeView(),
          ),
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: ChangeNotifierProvider<HomeViewModel>(
              create: (context) => HomeViewModel(),
              child: const HomeView(),
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(
              opacity:
                  CurveTween(curve: Curves.easeInOutCirc).animate(animation),
              child: child,
            ),
          ),
        )
      ],
    );
  }

  static StatefulShellBranch _storiesBranch() {
    return StatefulShellBranch(
      navigatorKey: _storiesKey,
      routes: [
        GoRoute(
          path: storiesRoute,
          builder: (context, state) => ChangeNotifierProvider(
            create: (_) => StoriesViewmodel(),
            child: const StoriesView(),
          ),
        )
      ],
    );
  }

  static StatefulShellBranch _settingsBranch() {
    return StatefulShellBranch(
      navigatorKey: _settingsKey,
      routes: [
        GoRoute(
          path: settingsRoute,
          builder: (context, state) => ChangeNotifierProvider(
            create: (_) => SettingsViewmodel(),
            child: const SettingsView(),
          ),
        )
      ],
    );
  }
}
