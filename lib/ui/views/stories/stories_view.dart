import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/generated/l10n.dart';
import 'package:pretty_affirmations/ui/views/stories/stories_viewmodel.dart';
import 'package:pretty_affirmations/ui/widgets/appbar_widget.dart';

class StoriesView extends StatelessWidget {
  const StoriesView({super.key});

  Widget _buildContent(BuildContext context, StoriesViewmodel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDateText(context),
        const Gap(15),
        if (viewModel.adService.isBannerAdLoaded) ...[
          viewModel.adService.showBannerAd(),
          const Gap(15),
        ],
        _buildTitle(viewModel.story.title),
        const Gap(12),
        _buildStoryContent(viewModel.story.content),
      ],
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        wordSpacing: 1.2,
      ),
    );
  }

  Widget _buildStoryContent(String content) {
    return Text(
      content,
      textAlign: TextAlign.justify,
      style: const TextStyle(fontSize: 20),
    );
  }

  Widget _buildDateText(BuildContext context) {
    return Text(
      DateTime.now().yearAbbrMonthDay,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        color: context.colors.primaryFixed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: S.of(context).stories),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Consumer<StoriesViewmodel>(
            builder: (context, viewModel, _) => viewModel.isBusy
                ? const Center(child: CircularProgressIndicator.adaptive())
                : _buildContent(context, viewModel),
          ),
        ),
      ),
    );
  }
}
