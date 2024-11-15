import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:intl/intl.dart';
import 'package:pretty_affirmations/app/router.dart';
import 'package:pretty_affirmations/app/theme.dart';
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
  Locale get _getCurrentLocale =>
      getIt<SettingsService>().currentLocale ?? Locale(Intl.getCurrentLocale());

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      constraints: const BoxConstraints(minWidth: 340),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            S.of(context).selectLanguage,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Divider(color: context.colors.primary, thickness: 2),
          const Gap(10),
          _languageItem(
            context,
            appLanguage: AppLanguage.en,
          ),
          _languageItem(
            context,
            appLanguage: AppLanguage.zh,
          ),
          _languageItem(
            context,
            appLanguage: AppLanguage.ru,
          ),
          _languageItem(
            context,
            appLanguage: AppLanguage.tr,
          ),
        ],
      ),
    );
  }

  Widget _languageItem(
    BuildContext context, {
    required AppLanguage appLanguage,
  }) {
    final bool isCurrent =
        _getCurrentLocale.languageCode == appLanguage.languageCode;

    return Column(
      children: [
        ListTile(
          onTap: () {
            Navigator.pop(context);
            if (!isCurrent) {
              widget.onLanguageSelect?.call(appLanguage.getLocale);
              context.go(AppRouter.splashRoute);
            }
          },
          leading: SvgPicture.asset(appLanguage.svg, height: 30),
          title: Text(
            appLanguage.name,
            style: const TextStyle(fontSize: 22),
          ),
          trailing: Icon(
            isCurrent ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: isCurrent ? Colors.redAccent : null,
          ),
        ),
        const Divider()
      ],
    );
  }
}
