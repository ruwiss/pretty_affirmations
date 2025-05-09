import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/app/router.dart';
import 'package:pretty_affirmations/generated/l10n.dart';
import 'package:pretty_affirmations/models/menu_item.dart';
import 'package:pretty_affirmations/ui/views/topics/topics_viewmodel.dart';
import 'package:pretty_affirmations/ui/views/topics/widgets/menu_grid.dart';
import 'package:pretty_affirmations/ui/views/topics/widgets/menu_item.dart';
import 'package:pretty_affirmations/ui/widgets/appbar_widget.dart';

class TopicsView extends StatelessWidget {
  const TopicsView({super.key});

  Widget _buildMenuItem(BuildContext context, MenuItem item,
      {bool disabled = false}) {
    return TopicsMenuItem(
      item: item,
      disabled: disabled,
      onTap:
          disabled ? null : () => context.go(AppRouter.homeRoute, extra: item),
    );
  }

  Widget _buildBody(BuildContext context, TopicsViewmodel viewModel) {
    return AnimatedOpacity(
      opacity: viewModel.isBusy ? 0 : 1,
      duration: const Duration(milliseconds: 500),
      child: TopicsMenuGrid(
        itemCount: viewModel.menuItems.length + 1,
        itemBuilder: (context, index) {
          if (index == viewModel.menuItems.length) {
            return _buildMenuItem(
              context,
              MenuItem.comingSoon(),
              disabled: true,
            );
          }
          return _buildMenuItem(context, viewModel.menuItems[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: S.of(context).topics),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Consumer<TopicsViewmodel>(
          builder: (context, viewModel, _) => _buildBody(context, viewModel),
        ),
      ),
    );
  }
}
