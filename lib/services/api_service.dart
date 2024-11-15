import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/models/menu_item.dart';

class ApiService {
  final HttpService _http = getIt<HttpService>();

  Future<List<MenuItem>> getCategories(String locale) async {
    final Result result = await _http.get('/categories.php?lang=$locale');

    if (result.hasValue) {
      return (result.value!.data['data'] as List)
          .map((e) => MenuItem.fromMap(e))
          .toList();
    } else {
      throw result.error!;
    }
  }
}
