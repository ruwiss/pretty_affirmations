import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/common/common.dart';
import 'package:pretty_affirmations/generated/l10n.dart';
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
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            mainAxisSpacing: 22,
            crossAxisSpacing: 25,
            mainAxisExtent: 100,
          ),
          itemCount: AppImages.menuImages().length,
          itemBuilder: (context, index) {
            final MenuItem item = AppImages.menuImages()[index];
            return _menuItem(context, item);
          },
        ),
      ),
    );
  }

  Widget _menuItem(BuildContext context, MenuItem item) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      highlightColor: context.colors.tertiary.withOpacity(.2),
      radius: 200,
      child: Ink(
        padding: const EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(item.imagePath),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Text(
            item.text.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: context.colors.surface,
              fontSize: 19,
            ),
          ),
        ),
      ),
    );
  }
}
