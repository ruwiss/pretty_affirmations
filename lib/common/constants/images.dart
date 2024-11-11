part of '../common.dart';

final class MenuItem {
  final String imagePath;
  final String text;

  const MenuItem({required this.imagePath, required this.text});
}

class AppImages {
  AppImages._();

  static List<MenuItem> menuImages() => [
        MenuItem(
            imagePath: "assets/images/menu/1.png",
            text: S.current.categoriesItem1),
        MenuItem(
            imagePath: "assets/images/menu/2.png",
            text: S.current.categoriesItem2),
        MenuItem(
            imagePath: "assets/images/menu/3.png",
            text: S.current.categoriesItem3),
        MenuItem(
            imagePath: "assets/images/menu/4.png",
            text: S.current.categoriesItem4),
        MenuItem(
            imagePath: "assets/images/menu/5.png",
            text: S.current.categoriesItem5),
        MenuItem(
            imagePath: "assets/images/menu/6.png",
            text: S.current.categoriesItem6),
        MenuItem(
            imagePath: "assets/images/menu/7.png",
            text: S.current.categoriesItem7),
        MenuItem(
            imagePath: "assets/images/menu/8.png",
            text: S.current.categoriesItem8),
        MenuItem(
            imagePath: "assets/images/menu/9.png",
            text: S.current.categoriesItem9),
        MenuItem(
            imagePath: "assets/images/menu/10.png",
            text: S.current.categoriesItem10),
        MenuItem(
            imagePath: "assets/images/menu/11.png",
            text: S.current.categoriesItem11),
        MenuItem(
            imagePath: "assets/images/menu/12.png",
            text: S.current.categoriesItem12),
        MenuItem(
            imagePath: "assets/images/menu/13.png",
            text: S.current.categoriesItem13),
        MenuItem(
            imagePath: "assets/images/menu/14.png",
            text: S.current.categoriesItem14),
      ];
}
