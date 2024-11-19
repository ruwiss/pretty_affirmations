import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/generated/l10n.dart';
import 'package:pretty_affirmations/ui/views/settings/widgets/language_dialog.dart';
import 'package:pretty_affirmations/ui/views/settings/widgets/select_categories_dialog.dart';
import 'package:pretty_affirmations/ui/widgets/appbar_widget.dart';
import 'package:pretty_affirmations/ui/widgets/bg_image.dart';

import 'settings_viewmodel.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: S.of(context).settings),
      body: Stack(
        children: [
          const BgImage(),
          _settingsView(context),
        ],
      ),
    );
  }

  Center _settingsView(BuildContext context) {
    final viewModel = context.read<SettingsViewmodel>();
    return Center(
      child: ListView(
        children: [
          _settingOption(
            context,
            onTap: () => LanguageDialog.show(context),
            title: S.of(context).language,
            description: S.of(context).languageOption,
          ),
          _settingOption(
            context,
            onTap: () => SelectCategoriesDialog.show(context),
            title: S.of(context).selectCategory,
            description: S.of(context).selectCategoryOption,
          ),
          _settingOption(
            context,
            onTap: () {},
            title: S.of(context).reminders,
            description: S.of(context).remindersOption,
          ),
          _settingOption(
            context,
            onTap: viewModel.onLeaveComment,
            title: S.of(context).leaveComment,
            description: S.of(context).leaveCommentOption,
          ),
          _settingOption(
            context,
            onTap: () => viewModel.onShareTap(context),
            title: S.of(context).share,
            description: S.of(context).shareOption,
          ),
          _settingOption(
            context,
            onTap: () {},
            title: S.of(context).privacyPolicy,
            description: S.of(context).privacyPolicyOption,
          ),
          _settingOption(
            context,
            onTap: () {},
            title: S.of(context).termsOfUse,
            description: S.of(context).termsOfUseOption,
          ),
        ],
      ),
    );
  }

  ListTile _settingOption(
    BuildContext context, {
    required String title,
    required String description,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        description,
        style: TextStyle(
          fontWeight: FontWeight.w300,
          fontSize: 16,
          color: context.colors.primaryFixed,
        ),
      ),
    );
  }
}
