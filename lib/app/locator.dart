import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/common/common.dart';
import 'package:pretty_affirmations/services/api_service.dart';
import 'package:pretty_affirmations/services/favourites_service.dart';
import 'package:pretty_affirmations/services/settings_service.dart';

Future<void> registerDependencies() async {
  // Settings Service
  getIt.registerSingleton<SettingsService>(SettingsService());

  getIt<HttpService>().setBaseUrl(kApiUrl);

  // Api Service
  getIt.registerLazySingleton(() => ApiService());

  // Favourites Service
  getIt.registerLazySingleton(() => FavouritesService());

  // Wait for all services to be ready
  await getIt.allReady();
}
