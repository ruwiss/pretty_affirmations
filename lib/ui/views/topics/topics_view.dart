import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/common/common.dart';
import 'package:pretty_affirmations/ui/widgets/appbar_widget.dart';

class TopicsView extends StatelessWidget {
  const TopicsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: 'Kategoriler',
        backgroundColor: context.colors.surface,
      ),
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
          itemCount: MenuImage.values.length,
          itemBuilder: (context, index) {
            final MenuImage image = MenuImage.values[index];
            return _menuItem(context, image);
          },
        ),
      ),
    );
  }

  Widget _menuItem(BuildContext context, MenuImage image) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      highlightColor: context.colors.tertiary.withOpacity(.2),
      radius: 200,
      child: Ink(
        padding: const EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(image.imagePath),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Text(
            image.text,
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
