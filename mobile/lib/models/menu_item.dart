import 'package:pretty_affirmations/common/common.dart';
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
        imageUrl = '$kBaseUrl${map['image_url']}',
        name = map['name'],
        imageType = MenuItemImageType.network;

  MenuItem.comingSoon()
      : id = '',
        categoryKey = 'coming_soon',
        imageUrl = AppImages.menuPlaceholder,
        name = S.current.comingSoon,
        imageType = MenuItemImageType.asset;
}
