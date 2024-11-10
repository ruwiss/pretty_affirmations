import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/generated/l10n.dart';
import 'package:pretty_affirmations/models/favourite_item.dart';
import 'package:pretty_affirmations/ui/widgets/appbar_widget.dart';

enum FavouritesPopupEntry {
  delete("Kaldır"),
  share("Paylaş");

  final String text;
  const FavouritesPopupEntry(this.text);
}

class FavouriesView extends StatelessWidget {
  FavouriesView({super.key});

  final List<FavouriteItem> _dummyItems = [
    FavouriteItem(
      id: 0,
      text: "Kendime güveniyorum ve hayatımda olumlu değişimler yaratıyorum",
      dateTime: DateTime.now(),
    ),
    FavouriteItem(
      id: 1,
      text: "Güçlüyüm ve her zorluğun üstesinden hoppala cubbala",
      dateTime: DateTime.now(),
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: S.of(context).favourites),
      body: Center(
        child: ListView.builder(
          itemCount: _dummyItems.length,
          itemBuilder: (context, index) {
            final FavouriteItem favourite = _dummyItems[index];
            return ListTile(
              title: Text(
                favourite.text,
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
              trailing: PopupMenuButton(
                onSelected: (choice) {},
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
              ),
            );
          },
        ),
      ),
    );
  }
}
