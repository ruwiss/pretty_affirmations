part of '../common.dart';

enum MenuImage {
  menu1("assets/images/menu/1.png", "KİŞİSEL GELİŞİM"),
  menu2("assets/images/menu/2.png", "ÖZ BAKIM"),
  menu3("assets/images/menu/3.png", "ÖZSAYGI-ÖZGÜVEN"),
  menu4("assets/images/menu/4.png", "İLİŞKİLER-İLETİŞİM"),
  menu5("assets/images/menu/5.png", "ŞÜKRAN"),
  menu6("assets/images/menu/6.png", "KARİYER-BAŞARI"),
  menu7("assets/images/menu/7.png", "SAĞLIK-İYİLİK"),
  menu8("assets/images/menu/8.png", "YARATICILIK-İLHAM"),
  menu9("assets/images/menu/9.png", "STRES YÖNETİMİ"),
  menu10("assets/images/menu/10.png", "RUHSAL GELİŞİM"),
  menu11("assets/images/menu/11.png", "MUTLULUK-NEŞE"),
  menu12("assets/images/menu/12.png", "AFFETME-BIRAKMA"),
  menu13("assets/images/menu/13.png", "UYKU-DİNLENME"),
  menu14("assets/images/menu/14.png", "YAKINDA...");

  final String text;
  final String imagePath;
  const MenuImage(this.imagePath, this.text);
}

class AppImages {
  AppImages._();

  static String get basePath => "assets/images";
}
