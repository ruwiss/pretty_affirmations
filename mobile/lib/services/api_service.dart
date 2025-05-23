import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/models/affirmation.dart';
import 'package:pretty_affirmations/models/app_settings/remote_settings.dart';
import 'package:pretty_affirmations/models/menu_item.dart';
import 'package:pretty_affirmations/models/story.dart';
import 'package:pretty_affirmations/services/settings_service.dart';

class ApiService {
  final HttpService _http = getIt<HttpService>();
  final SettingsService _settings = getIt<SettingsService>();

  // Kategorileri getiren fonksiyon
  Future<List<MenuItem>> getCategories(String locale,
      {bool filtered = true}) async {
    try {
      final result = await _http.get('/categories.php?lang=$locale');

      if (!result.hasValue) throw result.error!;

      final categories = (result.value!.data['data'] as List)
          .map((e) => MenuItem.fromMap(e))
          .toList();

      // Filtreleme istenmediyse tüm kategorileri döndür
      if (!filtered) return categories;

      // Seçilmemiş konuları al ve filtreleme yap
      final unselectedTopics = _settings.getUnselectedTopics();
      return categories.where((e) => !unselectedTopics.contains(e.id)).toList();
    } catch (e) {
      e.toString().log();
      rethrow;
    }
  }

  // Günlük hikayeyi getiren fonksiyon
  Future<Story> getDailyStory(String locale) async {
    try {
      final result = await _http.get('/daily-story.php?lang=$locale');

      if (!result.hasValue) throw result.error!;

      return Story.fromMap(result.value!.data['data']);
    } catch (e) {
      e.toString().log();
      rethrow;
    }
  }

  // Olumlamaları getiren fonksiyon
  Future<Affirmations?> getAffirmations({
    int page = 0,
    required String locale,
    MenuItem? categoryFilter,
    bool startFromLastRead = false,
  }) async {
    try {
      final String categories =
          categoryFilter?.id ?? await _getCategoriesString(locale);
      String url =
          '/affirmations.php?lang=$locale&categories=$categories&page=$page';
      if (startFromLastRead) {
        final lastReadId = _settings.getLastReadAffirmationId(
            categoryKey: categoryFilter?.categoryKey);
        url += "&lastId=$lastReadId";
      }

      final result = await _http.get(url);

      if (!result.hasValue) return null;

      return Affirmations.fromMap(result.value!.data);
    } catch (e) {
      e.toString().log();
      return null;
    }
  }

  // Kategori dizesini oluşturan yardımcı fonksiyon
  Future<String> _getCategoriesString(String locale) async {
    final categories = await getCategories(locale);
    return categories.map((e) => e.id).join(',');
  }

  // Rastgele olumlamaları getiren fonksiyon
  Future<Affirmations?> getRandomAffirmations({required String locale}) async {
    final String categories = await _getCategoriesString(locale);
    final result = await _http.get(
      '/random-affirmations.php?lang=$locale&categories=$categories',
    );

    if (!result.hasValue) return null;

    return Affirmations.fromMap(result.value!.data);
  }

  // Günlük giriş için sayaç tutan fonksiyon
  void dailyEntry(String locale) => _http.post("/daily-entry.php?lang=$locale");

  // Satın alım için API'ı bilgilendir
  void purchaseCounter() => _http.post("/purchases.php");

  // API'dan uygulama ayarlarını getiren fonksiyon
  Future<RemoteSettings> getRemoteSettings() async {
    final result = await _http.get('/settings.php');

    if (!result.hasValue) throw result.error!;

    return RemoteSettings.fromMap(result.value!.data['data']);
  }
}
