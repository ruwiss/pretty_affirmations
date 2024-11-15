import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/services/api_service.dart';
import 'package:pretty_affirmations/services/settings_service.dart';

Future<void> registerDependencies() async {
  // Settings Service
  getIt.registerSingleton<SettingsService>(SettingsService());

  getIt<HttpService>()
      .setBaseUrl('https://api.caltikoc.com.tr/affirmations/api');

  // Api Service
  getIt.registerLazySingleton(() => ApiService());

  // Wait for all services to be ready
  await getIt.allReady();
}
