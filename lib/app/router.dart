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
      _buildRoute(
          splashRoute, (context) => SplashViewmodel(), const SplashView()),
      ShellRoute(
        builder: (context, state, child) =>
            AppLayout(location: state.matchedLocation, child: child),
        routes: [
          _buildRoute(
            favouritesRoute,
            (context) => FavouritesViewmodel(),
            FavouriesView(),
          ),
          _buildRoute(
            topicsRoute,
            (context) => TopicsViewmodel()..init(context),
            const TopicsView(),
          ),
          _buildRoute(
            homeRoute,
            (context) => HomeViewModel(),
            const HomeView(),
          ),
          _buildRoute(
            storiesRoute,
            (context) => StoriesViewmodel()..init(context),
            const StoriesView(),
          ),
          _buildRoute(
            settingsRoute,
            (context) => SettingsViewmodel(),
            const SettingsView(),
          ),
        ],
      ),
    ],
  );

  static GoRoute _buildRoute<T extends ChangeNotifier>(
    String path,
    T Function(BuildContext) createViewModel,
    Widget child,
  ) {
    return GoRoute(
      path: path,
      pageBuilder: (context, state) => CustomTransitionPage(
        child: ChangeNotifierProvider<T>(
          create: createViewModel,
          child: child,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
          child: child,
        ),
      ),
    );
  }
}
