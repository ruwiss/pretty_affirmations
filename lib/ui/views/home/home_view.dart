import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/generated/l10n.dart';
import 'package:pretty_affirmations/ui/views/home/home_viewmodel.dart';
import 'package:pretty_affirmations/ui/views/home/widgets/post_page.dart';
import 'package:pretty_affirmations/ui/widgets/appbar_widget.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, value, child) {
        return Scaffold(
          appBar: AppBarWidget(
            title: value.affirmationCategory?.name ?? S.of(context).flow,
            transparentBg: true,
          ),
          extendBodyBehindAppBar: true,
          body: !value.isBusy && value.affirmations.data.isEmpty
              ? _noAffirmationsView(context)
              : Skeletonizer(
                  enabled: value.isBusy,
                  child: PageView.builder(
                    controller: value.pageController,
                    pageSnapping: true,
                    onPageChanged: value.onPageIndexChanged,
                    itemCount: value.affirmations.data.length,
                    itemBuilder: (context, index) {
                      final affirmation = value.affirmations.data[index];
                      return PostPage(
                        index: index,
                        affirmation: affirmation,
                        viewModel: value,
                        isFavourite: value.isFavourite(affirmation),
                        onLikeTap: () => value.toggleFavourite(affirmation),
                        onShareTap: () =>
                            value.onShareTap(context, affirmation),
                      );
                    },
                  ),
                ),
        );
      },
    );
  }

  Center _noAffirmationsView(BuildContext context) {
    return Center(
      child: Text(
        S.of(context).noAffirmations,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 26),
      ),
    );
  }
}
