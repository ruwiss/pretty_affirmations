import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/generated/l10n.dart';
import 'package:pretty_affirmations/services/schedule_service.dart';
import 'package:pretty_affirmations/services/settings_service.dart';

class NotificationSettingDialog extends StatefulWidget {
  const NotificationSettingDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => FluidDialog(
        rootPage: FluidDialogPage(
          alignment: Alignment.center,
          builder: (context) => const NotificationSettingDialog(),
        ),
      ),
    );
  }

  @override
  State<NotificationSettingDialog> createState() =>
      _NotificationSettingDialogState();
}

class _NotificationSettingDialogState extends State<NotificationSettingDialog> {
  int _notificationsPerDay =
      getIt<SettingsService>().getDailyNotificationCount();

  void _handleSave(BuildContext context) {
    getIt<SettingsService>().setDailyNotificationCount(_notificationsPerDay);
    getIt<ScheduleService>().checkAndScheduleAffirmations(force: true);
    Navigator.pop(context);
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
          const Gap(20),
          _buildNotificationsPerDaySelector(context),
          const Gap(20),
          _buildSaveButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Text(
          S.of(context).dailyNotificationSetting,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Divider(color: context.colors.primary, thickness: 2),
      ],
    );
  }

  Widget _buildNotificationsPerDaySelector(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: List.generate(5, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: ChoiceChip.elevated(
            label: Text(
              '$index',
              style: const TextStyle(fontSize: 18),
            ),
            showCheckmark: false,
            selected: _notificationsPerDay == index,
            selectedColor: context.colors.tertiary,
            onSelected: (selected) {
              if (selected) {
                setState(() => _notificationsPerDay = index);
              }
            },
          ),
        );
      }),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _handleSave(context),
      child: Text(S.of(context).ok),
    );
  }
}
