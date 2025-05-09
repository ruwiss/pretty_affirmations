import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/common/common.dart';

class BgImage extends StatelessWidget {
  const BgImage({super.key});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      AppVectors.splashBgLogo,
      colorFilter: context.colors.onSurface.withOpacity(.05).withSrcInFilter(),
    );
  }
}
