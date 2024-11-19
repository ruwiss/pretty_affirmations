import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/generated/l10n.dart';
import 'package:pretty_affirmations/models/favourite_item.dart';
import 'package:pretty_affirmations/models/favourites/favourites.dart';
import 'package:pretty_affirmations/ui/views/favourites/favourites_viewmodel.dart';
import 'package:pretty_affirmations/ui/widgets/appbar_widget.dart';

enum FavouritesPopupEntry {
  delete("Kaldır"),
  share("Paylaş");

  final String text;
  const FavouritesPopupEntry(this.text);
}

class FavouriesView extends StatelessWidget {
  const FavouriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: S.of(context).favourites),
      body: Center(
        child: Consumer<FavouritesViewmodel>(
          builder: (context, value, child) {
            if (value.favourites.isEmpty) {
              return _noFavourites(context);
            } else {
              return ListView.builder(
                itemCount: value.favourites.length,
                itemBuilder: (context, index) {
                  final favourite = value.favourites[index];
                  return ListTile(
                    title: Text(
                      favourite.content,
                      style: const TextStyle(fontSize: 18),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      favourite.dateTime.yearAbbrMonthDay,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        color: context.colors.primaryFixed,
                      ),
                    ),
                    trailing: _actionButtons(context,
                        value: value, favourite: favourite),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  Center _noFavourites(BuildContext context) {
    return Center(
      child: Text(
        S.of(context).noFavourites,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 26),
      ),
    );
  }

  Widget _actionButtons(BuildContext context,
      {required FavouritesViewmodel value, required Favourites favourite}) {
    return PopupMenuButton(
      onSelected: (choice) {
        if (choice == FavouritesPopupEntry.delete) {
          value.onDeleteTap(favourite);
        } else if (choice == FavouritesPopupEntry.share) {
          value.onShareTap(favourite);
        }
      },
      menuPadding: EdgeInsets.zero,
      itemBuilder: (context) => FavouritesPopupEntry.values.map(
        (choice) {
          return PopupMenuItem<FavouritesPopupEntry>(
            value: choice,
            child: Text(
              choice.text,
              style: const TextStyle(fontSize: 18),
            ),
          );
        },
      ).toList(),
      child: Icon(
        Icons.more_vert,
        size: 30,
        color: context.colors.primaryFixed,
      ),
    );
  }
}
