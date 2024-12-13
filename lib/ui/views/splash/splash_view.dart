import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/common/common.dart';
import 'package:pretty_affirmations/ui/widgets/bg_image.dart';

import 'splash_viewmodel.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    // Animasyonu başlat
    _controller.forward();

    context.read<SplashViewmodel>().init(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.tertiary,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            const BgImage(),
            _splashView(context),
          ],
        ),
      ),
    );
  }

  Widget _splashView(BuildContext context) {
    return Column(
      children: [
        const Gap(165),
        SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SvgPicture.asset(
              AppVectors.logo,
              width: 100,
              colorFilter: context.colors.onSurface.withSrcInFilter(),
            ),
          ),
        ),
        const Gap(150),
        FadeTransition(
          opacity: _fadeAnimation,
          child: SvgPicture.asset(
            AppVectors.title,
            width: 280,
            colorFilter: context.colors.onSurface.withSrcInFilter(),
          ),
        ),
        const Spacer(),
        FadeTransition(
          opacity: _fadeAnimation,
          child: Text(
            'by PrettyCat',
            style: TextStyle(
              color: context.colors.onSurface.withOpacity(.5),
            ),
          ),
        ),
        const Gap(18),
      ],
    );
  }
}
