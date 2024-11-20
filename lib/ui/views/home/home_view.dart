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
      builder: (context, viewModel, _) => Scaffold(
        appBar: AppBarWidget(
          title: viewModel.affirmationCategory?.name ?? S.of(context).flow,
          transparentBg: true,
        ),
        extendBodyBehindAppBar: true,
        body: _buildBody(context, viewModel),
      ),
    );
  }

  Widget _buildBody(BuildContext context, HomeViewModel viewModel) {
    if (!viewModel.isBusy && viewModel.affirmations.data.isEmpty) {
      return _buildEmptyView(context);
    }

    return _buildAffirmationsList(viewModel);
  }

  Widget _buildAffirmationsList(HomeViewModel viewModel) {
    return Skeletonizer(
      enabled: viewModel.isBusy,
      child: PageView.builder(
        controller: viewModel.pageController,
        pageSnapping: true,
        onPageChanged: viewModel.onPageIndexChanged,
        itemCount: viewModel.affirmations.data.length,
        itemBuilder: (context, index) => _buildAffirmationPage(
          context,
          viewModel,
          index,
        ),
      ),
    );
  }

  Widget _buildAffirmationPage(
    BuildContext context,
    HomeViewModel viewModel,
    int index,
  ) {
    final affirmation = viewModel.affirmations.data[index];
    return PostPage(
      index: index,
      affirmation: affirmation,
      viewModel: viewModel,
      isFavourite: viewModel.isFavourite(affirmation),
      onLikeTap: () => viewModel.toggleFavourite(affirmation),
      onShareTap: () => viewModel.onShareTap(context, affirmation),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: Text(
        S.of(context).noAffirmations,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 26),
      ),
    );
  }
}
