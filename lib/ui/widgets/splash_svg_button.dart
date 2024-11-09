import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';

class SplashSvgButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String svg;
  final double svgWidth;
  final double? radius;
  final ColorFilter? colorFilter;
  final EdgeInsets? padding;
  final Function(BuildContext context, Widget child)? builder;
  const SplashSvgButton({
    super.key,
    this.onTap,
    required this.svg,
    this.svgWidth = 40,
    this.radius,
    this.colorFilter,
    this.padding,
    this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkResponse(
        onTap: onTap,
        radius: radius,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        child: builder != null ? builder!(context, _icon()) : _icon(),
      ),
    );
  }

  Padding _icon() {
    return Padding(
      padding: padding ?? const EdgeInsets.all(18),
      child: SvgPicture.asset(
        svg,
        colorFilter: colorFilter,
        width: svgWidth,
      ),
    );
  }
}
