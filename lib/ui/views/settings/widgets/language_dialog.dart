import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:intl/intl.dart';
import 'package:pretty_affirmations/app/router.dart';
import 'package:pretty_affirmations/app/base.dart';
import 'package:pretty_affirmations/common/enums/app_language.dart';
import 'package:pretty_affirmations/generated/l10n.dart';
import 'package:pretty_affirmations/services/settings_service.dart';

class LanguageDialog extends StatefulWidget {
  final Function(Locale locale)? onLanguageSelect;
  const LanguageDialog({super.key, this.onLanguageSelect});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => FluidDialog(
        rootPage: FluidDialogPage(
          alignment: Alignment.center,
          builder: (context) => LanguageDialog(
            onLanguageSelect: (locale) =>
                context.read<AppBase>().changeLocale(locale),
          ),
        ),
      ),
    );
  }

  @override
  State<LanguageDialog> createState() => _LanguageDialogState();
}

class _LanguageDialogState extends State<LanguageDialog> {
  Locale get _currentLocale =>
      getIt<SettingsService>().currentLocale ?? Locale(Intl.getCurrentLocale());

  void _handleLanguageSelect(BuildContext context, AppLanguage language) {
    final bool isCurrent = _currentLocale.languageCode == language.languageCode;
    Navigator.pop(context);
    if (!isCurrent) {
      widget.onLanguageSelect?.call(language.getLocale);
      context.go(AppRouter.splashRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      constraints: const BoxConstraints(minWidth: 340),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          const Gap(10),
          ...AppLanguage.values.map(
            (lang) => _LanguageItem(
              language: lang,
              isSelected: _currentLocale.languageCode == lang.languageCode,
              onTap: () => _handleLanguageSelect(context, lang),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Text(
          S.of(context).selectLanguage,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Divider(color: context.colors.primary, thickness: 2),
      ],
    );
  }
}

class _LanguageItem extends StatelessWidget {
  final AppLanguage language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageItem({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: SvgPicture.asset(language.svg, height: 30),
          title: Text(
            language.name,
            style: const TextStyle(fontSize: 22),
          ),
          trailing: Icon(
            isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: isSelected ? Colors.redAccent : null,
          ),
        ),
        const Divider()
      ],
    );
  }
}
