import 'package:flutter/material.dart';
import 'package:pretty_affirmations/ui/widgets/appbar_widget.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBarWidget(title: 'Ayarlar'),
      body: Center(
        child: Column(
          children: [],
        ),
      ),
    );
  }
}
