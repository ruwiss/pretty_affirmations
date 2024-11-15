import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/generated/l10n.dart';
import 'package:pretty_affirmations/models/menu_item.dart';
import 'package:pretty_affirmations/ui/views/topics/topics_viewmodel.dart';
import 'package:pretty_affirmations/ui/views/topics/widgets/menu_grid.dart';
import 'package:pretty_affirmations/ui/views/topics/widgets/menu_item.dart';
import 'package:pretty_affirmations/ui/widgets/appbar_widget.dart';

class TopicsView extends StatelessWidget {
  const TopicsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: S.of(context).topics),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Consumer<TopicsViewmodel>(
          builder: (context, value, child) {
            if (value.isBusy) {
              return TopicsMenuGrid(
                itemCount: 14,
                itemBuilder: (context, i) => TopicsMenuItem(
                  item: MenuItem.comingSoon(),
                  skeletonEnabled: true,
                ),
              );
            } else {
              return TopicsMenuGrid(
                itemCount: value.menuItems.length + 1,
                itemBuilder: (context, i) {
                  if (i != value.menuItems.length) {
                    final MenuItem item = value.menuItems[i];
                    return TopicsMenuItem(item: item);
                  } else {
                    return TopicsMenuItem(
                      item: MenuItem.comingSoon(),
                      disabled: true,
                    );
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }
}
