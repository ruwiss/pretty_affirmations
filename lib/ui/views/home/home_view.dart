import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/generated/l10n.dart';
import 'package:pretty_affirmations/ui/views/home/home_viewmodel.dart';
import 'package:pretty_affirmations/ui/views/home/widgets/post_page.dart';
import 'package:pretty_affirmations/ui/widgets/appbar_widget.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().setPageController(_pageController);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: S.of(context).flow, transparentBg: true),
      extendBodyBehindAppBar: true,
      body: Consumer<HomeViewModel>(
        builder: (context, value, child) {
          return PageView.builder(
            controller: _pageController,
            onPageChanged: value.onPageIndexChanged,
            itemCount: value.affirmations.data.length,
            itemBuilder: (context, index) {
              return PostPage(
                index: index,
                affirmation: value.affirmations.data[index],
                viewModel: value,
              );
            },
            pageSnapping: true,
          );
        },
      ),
    );
  }
}
