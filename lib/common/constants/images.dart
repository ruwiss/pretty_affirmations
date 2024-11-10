part of '../common.dart';

final class MenuItem {
  final String imagePath;
  final String text;

  const MenuItem({required this.imagePath, required this.text});
}

class AppImages {
  AppImages._();

  static String get _basePath => "assets/images";
  static String get _menuBasePath => "assets/images/menu";

  static List<MenuItem> menuImages() => [
        MenuItem(
            imagePath: "$_menuBasePath/1.png", text: S.current.categoriesItem1),
        MenuItem(
            imagePath: "$_menuBasePath/2.png", text: S.current.categoriesItem2),
        MenuItem(
            imagePath: "$_menuBasePath/3.png", text: S.current.categoriesItem3),
        MenuItem(
            imagePath: "$_menuBasePath/4.png", text: S.current.categoriesItem4),
        MenuItem(
            imagePath: "$_menuBasePath/5.png", text: S.current.categoriesItem5),
        MenuItem(
            imagePath: "$_menuBasePath/6.png", text: S.current.categoriesItem6),
        MenuItem(
            imagePath: "$_menuBasePath/7.png", text: S.current.categoriesItem7),
        MenuItem(
            imagePath: "$_menuBasePath/8.png", text: S.current.categoriesItem8),
        MenuItem(
            imagePath: "$_menuBasePath/9.png", text: S.current.categoriesItem9),
        MenuItem(
            imagePath: "$_menuBasePath/10.png",
            text: S.current.categoriesItem10),
        MenuItem(
            imagePath: "$_menuBasePath/11.png",
            text: S.current.categoriesItem11),
        MenuItem(
            imagePath: "$_menuBasePath/12.png",
            text: S.current.categoriesItem12),
        MenuItem(
            imagePath: "$_menuBasePath/13.png",
            text: S.current.categoriesItem13),
        MenuItem(
            imagePath: "$_menuBasePath/14.png",
            text: S.current.categoriesItem14),
      ];
}
