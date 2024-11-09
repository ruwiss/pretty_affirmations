import 'package:flutter/material.dart';
import 'package:pretty_affirmations/ui/widgets/appbar_widget.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'colors.dart';
import 'widgets/action_buttons.dart';
import 'widgets/quotes_icon.dart';
import 'widgets/resonsive_text.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentColorIndex = 0;

  Color _currentColor() {
    if (_currentColorIndex > HomeViewColors.colors.length - 1) {
      _currentColorIndex = 0;
    }
    final color = HomeViewColors.colors[_currentColorIndex];
    _currentColorIndex++;
    return color;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(title: 'Akış'),
      extendBodyBehindAppBar: true,
      body: LiquidSwipe(
        pages: List.generate(
          40,
          (index) => _postPage(
            text:
                "Kendime güveniyorum ve hayatımda olumlu değişimler yaratıyorum. $index",
          ),
        ),
      ),
    );
  }

  Widget _postPage({required String text}) {
    final Color currentColor = _currentColor();
    final bool isReversed = currentColor.computeLuminance() < .5;
    return Container(
      padding: const EdgeInsets.only(top: 120),
      color: currentColor,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          QuoteIcon(reversedColor: isReversed),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ResponsiveText(
              text: text,
              reversedColor: isReversed,
            ),
          ),
          ActionButtons(
            onLikeTap: () {},
            onShareTap: () {},
            reversedColor: isReversed,
          ),
        ],
      ),
    );
  }
}
