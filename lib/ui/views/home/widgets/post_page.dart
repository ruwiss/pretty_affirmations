import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/app/base.dart';
import 'package:pretty_affirmations/models/affirmation.dart';
import 'package:pretty_affirmations/ui/views/home/home_viewmodel.dart';

import 'action_buttons.dart';
import 'quotes_icon.dart';
import 'resonsive_text.dart';

class PostPage extends StatefulWidget {
  final int index;
  final Affirmation affirmation;
  final HomeViewModel viewModel;
  const PostPage({
    super.key,
    required this.index,
    required this.affirmation,
    required this.viewModel,
  });

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage>
    with SingleTickerProviderStateMixin {
  late Color _currentColor;
  bool _isReversed = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  void _setCurrentColor() {
    final List<Color> homeColors = context.read<AppBase>().homeColors;
    _currentColor = homeColors[widget.index % homeColors.length];
    _isReversed = _currentColor.computeLuminance() < .5;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _setCurrentColor();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.only(top: 120),
          color: _currentColor,
          alignment: Alignment.center,
          child: FadeTransition(
            opacity: _animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.2),
                end: Offset.zero,
              ).animate(_animation),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  QuoteIcon(reversedColor: _isReversed),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: ResponsiveText(
                      text: widget.affirmation.content,
                      reversedColor: _isReversed,
                    ),
                  ),
                  ActionButtons(
                    onLikeTap: () {},
                    onShareTap: () {},
                    showFirstPageButton:
                        widget.viewModel.showGoToFirstPageButton(widget.index),
                    onFirstPageTap: widget.viewModel.goToFirstPage,
                    reversedColor: _isReversed,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
