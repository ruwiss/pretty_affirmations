import 'package:flutter/material.dart';
import 'package:pretty_affirmations/generated/l10n.dart';
import 'package:pretty_affirmations/ui/widgets/appbar_widget.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: S.of(context).settings),
      body: const Center(
        child: Column(
          children: [],
        ),
      ),
    );
  }
}
