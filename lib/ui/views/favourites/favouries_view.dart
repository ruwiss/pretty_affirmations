import 'package:flutter/material.dart';
import 'package:pretty_affirmations/ui/widgets/appbar_widget.dart';

class FavouriesView extends StatelessWidget {
  const FavouriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBarWidget(title: 'Favoriler'),
      body: Center(
        child: Column(
          children: [],
        ),
      ),
    );
  }
}
