part of '../common.dart';

extension ColorExtensions on Color {
  ColorFilter withSrcInFilter() => ColorFilter.mode(this, BlendMode.srcIn);
}
