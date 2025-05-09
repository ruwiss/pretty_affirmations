import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/models/favourites/favourites.dart';

class PopupFavourite extends StatelessWidget {
  final Favourites favourite;
  const PopupFavourite({super.key, required this.favourite});

  static void show(BuildContext context, Favourites favourite) {
    showDialog(
      context: context,
      builder: (context) => FluidDialog(
        rootPage: FluidDialogPage(
          alignment: Alignment.center,
          builder: (context) => PopupFavourite(favourite: favourite),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      constraints: const BoxConstraints(maxWidth: 340),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            favourite.content,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24),
          ),
          const Gap(10),
          Text(
            favourite.dateTime.yearAbbrMonthDay,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: context.colors.primaryFixed),
          ),
        ],
      ),
    );
  }
}
