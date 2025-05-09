import 'package:flutter/material.dart';

class TopicsMenuGrid extends StatelessWidget {
  final int itemCount;
  final NullableIndexedWidgetBuilder itemBuilder;

  const TopicsMenuGrid(
      {super.key, required this.itemCount, required this.itemBuilder});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisSpacing: 22,
        crossAxisSpacing: 25,
        mainAxisExtent: 100,
      ),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}
