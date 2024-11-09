import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/common/common.dart';

import 'splash_viewmodel.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    context.read<SplashViewmodel>().init(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.tertiary,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            _splashBgImage(context),
            _splashView(context),
          ],
        ),
      ),
    );
  }

  Widget _splashBgImage(BuildContext context) {
    return SvgPicture.asset(
      AppVectors.splashBgLogo,
      colorFilter: context.colors.onSurface.withOpacity(.05).withSrcInFilter(),
    );
  }

  Column _splashView(BuildContext context) {
    return Column(
      children: [
        const Gap(165),
        SvgPicture.asset(
          AppVectors.logo,
          width: 100,
          colorFilter: context.colors.onSurface.withSrcInFilter(),
        ),
        const Gap(150),
        SvgPicture.asset(
          AppVectors.title,
          width: 280,
          colorFilter: context.colors.onSurface.withSrcInFilter(),
        ),
        const Spacer(),
        Text(
          'by PrettyCat',
          style: TextStyle(
            color: context.colors.onSurface.withOpacity(.5),
          ),
        ),
        const Gap(18),
      ],
    );
  }
}
