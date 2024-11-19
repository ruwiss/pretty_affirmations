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
    final unselectedTopics = _settings.getUnselectedTopics();
    final result = await _http.get('/categories.php?lang=$locale');

    if (result.hasValue) {
      final categories = (result.value!.data['data'] as List)
          .map((e) => MenuItem.fromMap(e))
          .toList();
      if (!filtered) return categories;
      return categories.where((e) => !unselectedTopics.contains(e.id)).toList();
    } else {
      result.error.toString().log();
      throw result.error!;
    }
  }

  Future<Story> getDailyStory(String locale) async {
    final result = await _http.get('/daily-story.php?lang=$locale');

    if (result.hasValue) {
      return Story.fromMap(result.value!.data['data']);
    } else {
      result.error.toString().log();
      throw result.error!;
    }
  }

  Future<Affirmations?> getAffirmations({
    int page = 0,
    required String locale,
    String? categoryFilter,
  }) async {
    if (categoryFilter == null) {
      final Iterable<String> categories =
          await getCategories(locale).then((e) => e.map((i) => i.id));
      categoryFilter = categories.join(",");
    }

    final lastReadAffirmationId = _settings.getLastReadAffirmationId();

    final String lastIdParam =
        lastReadAffirmationId != null ? '&lastId=$lastReadAffirmationId' : '';

    final result = await _http.get(
      '/affirmations.php?lang=$locale&categories=$categoryFilter&page=$page$lastIdParam',
    );

    if (result.hasValue) {
      final Map<String, dynamic> data = result.value!.data;
      final affirmations = Affirmations.fromMap(data);
      return affirmations;
    } else {
      return null;
    }
  }
}
