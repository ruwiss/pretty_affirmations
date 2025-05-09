import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/app/base.dart';
import 'package:pretty_affirmations/app/router.dart';
import 'package:pretty_affirmations/generated/l10n.dart';

class AnimatedRemoveAdsButton extends StatefulWidget {
  const AnimatedRemoveAdsButton({super.key});

  @override
  State<AnimatedRemoveAdsButton> createState() => _AnimatedRemoveAdsButtonState();
}

class _AnimatedRemoveAdsButtonState extends State<AnimatedRemoveAdsButton>
    with TickerProviderStateMixin {
  late final AnimationController _breathingController;
  late final Animation<double> _slideAnimation;
  late final Animation<Offset> _breathingAnimation;
  late final AnimationController _initialSlideController;
  late final AnimationController _swingController;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _initialSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _slideAnimation = Tween<double>(
      begin: -100.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _initialSlideController,
      curve: Curves.easeOutCubic,
    ));

    _breathingAnimation = Tween<Offset>(
      begin: const Offset(-0.05, 0),
      end: const Offset(0.05, 0),
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));

    _swingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(
      begin: -0.03,
      end: 0.03,
    ).animate(CurvedAnimation(
      parent: _swingController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _initialSlideController.dispose();
    _swingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(
          [_initialSlideController, _breathingController, _swingController]),
      builder: (context, child) {
        return Positioned(
          top: 48,
          right: _slideAnimation.value,
          child: Transform(
            alignment: Alignment.topCenter,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateZ(_rotationAnimation.value),
            child: SlideTransition(
              position: _breathingAnimation,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Ana buton
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFF6B6B),
                          Color(0xFFFF9F43),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B6B).withOpacity(0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.push(AppRouter.pricingRoute),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.workspace_premium_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                S.of(context).removeAds,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Çarpı butonu
                  Positioned(
                    left: -8,
                    top: -8,
                    child: GestureDetector(
                      onTap: () => context.read<AppBase>().hideRemoveAdsButton(),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
