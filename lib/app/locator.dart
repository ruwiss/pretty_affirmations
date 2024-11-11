import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/services/settings_service.dart';

Future<void> registerDependencies() async {
  // Settings Service
  getIt.registerSingleton<SettingsService>(SettingsService());

  // Other Services
  // ...

  // Wait for all services to be ready
  await getIt.allReady();
}
