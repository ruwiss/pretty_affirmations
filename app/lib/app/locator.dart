import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/common/common.dart';
import 'package:pretty_affirmations/services/api_service.dart';
import 'package:pretty_affirmations/services/favourites_service.dart';
import 'package:pretty_affirmations/services/schedule_service.dart';
import 'package:pretty_affirmations/services/settings_service.dart';

Future<void> registerDependencies() async {
  // Settings Service
  getIt.registerSingleton<SettingsService>(SettingsService());

  getIt<HttpService>().setBaseUrl(kApiUrl);

  // Api Service
  getIt.registerSingletonAsync<ApiService>(() async {
    final apiService = ApiService();
    // API üzerindeki ayarları al
    final settings = await apiService.getRemoteSettings();
    // Uygulama ayarlarına kaydet
    getIt<SettingsService>().setAdsEnabled(settings.adsEnabled);
    return apiService;
  });

  // Favourites Service
  getIt.registerLazySingleton(() => FavouritesService());

  // Schedule Service
  getIt.registerLazySingleton(() => ScheduleService());

  // Wait for all services to be ready
  await getIt.allReady();
}
