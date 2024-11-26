import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/models/affirmation.dart';
import 'package:pretty_affirmations/models/menu_item.dart';
import 'package:pretty_affirmations/models/story.dart';
import 'package:pretty_affirmations/services/settings_service.dart';

class ApiService {
  final HttpService _http = getIt<HttpService>();
  final SettingsService _settings = getIt<SettingsService>();

  Future<List<MenuItem>> getCategories(String locale,
      {bool filtered = true}) async {
    try {
      final result = await _http.get('/categories.php?lang=$locale');

      if (!result.hasValue) throw result.error!;

      final categories = (result.value!.data['data'] as List)
          .map((e) => MenuItem.fromMap(e))
          .toList();

      if (!filtered) return categories;

      final unselectedTopics = _settings.getUnselectedTopics();
      return categories.where((e) => !unselectedTopics.contains(e.id)).toList();
    } catch (e) {
      e.toString().log();
      rethrow;
    }
  }

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

  Future<Affirmations?> getAffirmations({
    int page = 0,
    required String locale,
    String? categoryFilter,
  }) async {
    try {
      final String categories =
          categoryFilter ?? await _getCategoriesString(locale);
      final String lastIdParam = await _getLastReadIdParam();

      final result = await _http.get(
        '/affirmations.php?lang=$locale&categories=$categories&page=$page$lastIdParam',
      );

      if (!result.hasValue) return null;

      return Affirmations.fromMap(result.value!.data);
    } catch (e) {
      e.toString().log();
      return null;
    }
  }

  Future<String> _getCategoriesString(String locale) async {
    final categories = await getCategories(locale);
    return categories.map((e) => e.id).join(',');
  }

  Future<String> _getLastReadIdParam() async {
    final lastReadId = _settings.getLastReadAffirmationId();
    return lastReadId != null ? '&lastId=$lastReadId' : '';
  }

  Future<Affirmations?> getRandomAffirmations({required String locale}) async {
    final String categories = await _getCategoriesString(locale);
    final result = await _http.get(
      '/random-affirmations.php?lang=$locale&categories=$categories',
    );

    if (!result.hasValue) return null;

    return Affirmations.fromMap(result.value!.data);
  }

  void dailyEntry(String locale) => _http.post("/daily-entry.php?lang=$locale");
}
