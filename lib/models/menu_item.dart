import 'package:pretty_affirmations/generated/l10n.dart';

enum MenuItemImageType { network, asset }

final class MenuItem {
  final String id;
  final String categoryKey;
  final String imageUrl;
  final String name;
  final MenuItemImageType imageType;

  MenuItem({
    required this.id,
    required this.categoryKey,
    required this.imageUrl,
    required this.name,
    required this.imageType,
  });

  MenuItem.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        categoryKey = map['category_key'],
        imageUrl = 'https://api.caltikoc.com.tr/${map['image_url']}',
        name = map['name'],
        imageType = MenuItemImageType.network;

  MenuItem.comingSoon()
      : id = '',
        categoryKey = 'comig_soon',
        imageUrl = 'assets/images/menu/14.png',
        name = S.current.comingSoon,
        imageType = MenuItemImageType.asset;
}
