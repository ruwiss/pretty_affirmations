import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/generated/l10n.dart';
import 'package:pretty_affirmations/ui/views/stories/stories_viewmodel.dart';
import 'package:pretty_affirmations/ui/widgets/appbar_widget.dart';

class StoriesView extends StatelessWidget {
  const StoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: S.of(context).stories),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: SingleChildScrollView(
          child: Consumer<StoriesViewmodel>(
            builder: (context, value, child) => value.isBusy
                ? const Center(child: CircularProgressIndicator.adaptive())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _datetimeNowText(context),
                      const Gap(15),
                      Text(
                        value.story.title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          wordSpacing: 1.2,
                        ),
                      ),
                      const Gap(12),
                      Text(
                        value.story.content,
                        textAlign: TextAlign.justify,
                        style: const TextStyle(fontSize: 20),
                      )
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Text _datetimeNowText(BuildContext context) {
    return Text(
      DateTime.now().yearAbbrMonthDay,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        color: context.colors.primaryFixed,
      ),
    );
  }
}
