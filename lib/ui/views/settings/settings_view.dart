import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/generated/l10n.dart';
import 'package:pretty_affirmations/ui/views/settings/widgets/language_dialog.dart';
import 'package:pretty_affirmations/ui/views/settings/widgets/notification_setting_dialog.dart';
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
          _buildSettingsList(context),
        ],
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    final viewModel = context.read<SettingsViewmodel>();
    final s = S.of(context);

    return ListView(
      children: [
        _buildSettingTile(
          context: context,
          onTap: () => LanguageDialog.show(context),
          title: s.language,
          description: s.languageOption,
        ),
        _buildSettingTile(
          context: context,
          onTap: () => SelectCategoriesDialog.show(context),
          title: s.selectCategory,
          description: s.selectCategoryOption,
        ),
        _buildSettingTile(
          context: context,
          onTap: () => NotificationSettingDialog.show(context),
          title: s.reminders,
          description: s.remindersOption,
        ),
        _buildSettingTile(
          context: context,
          onTap: viewModel.onLeaveComment,
          title: s.leaveComment,
          description: s.leaveCommentOption,
        ),
        _buildSettingTile(
          context: context,
          onTap: () => viewModel.onShareTap(context),
          title: s.share,
          description: s.shareOption,
        ),
        _buildSettingTile(
          context: context,
          onTap: () {},
          title: s.privacyPolicy,
          description: s.privacyPolicyOption,
        ),
        _buildSettingTile(
          context: context,
          onTap: () {},
          title: s.termsOfUse,
          description: s.termsOfUseOption,
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required BuildContext context,
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
