import 'package:flutter/material.dart';
import 'package:pretty_affirmations/ui/widgets/appbar_widget.dart';

class TopicsView extends StatelessWidget {
  const TopicsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBarWidget(title: 'Kategoriler'),
      body: Center(
        child: Column(
          children: [],
        ),
      ),
    );
  }
}
