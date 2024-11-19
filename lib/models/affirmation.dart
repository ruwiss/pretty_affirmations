import 'favourites/favourites.dart';

class Affirmations {
  List<Affirmation> data;
  int page;
  int total;

  Affirmations({
    required this.data,
    required this.page,
    required this.total,
  });

  Affirmations.fromMap(Map<String, dynamic> map)
      : data =
            (map['data'] as List).map((e) => Affirmation.fromMap(e)).toList(),
        page = map['page'],
        total = map['count'];
}

final class Affirmation {
  final String id;
  final String content;
  final String categoryKey;
  final String categoryName;

  Affirmation({
    required this.id,
    required this.content,
    required this.categoryKey,
    required this.categoryName,
  });

  Affirmation.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        content = map['content'],
        categoryKey = map['category_key'],
        categoryName = map['category_name'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'category_key': categoryKey,
        'category_name': categoryName,
      };

  Favourites toFavouriteModel() {
    return Favourites(
      id,
      content,
      categoryKey,
      categoryName,
      DateTime.now(),
    );
  }
}
