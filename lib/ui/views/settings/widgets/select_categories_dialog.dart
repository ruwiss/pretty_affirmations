import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/app/theme.dart';
import 'package:pretty_affirmations/generated/l10n.dart';
import 'package:pretty_affirmations/models/menu_item.dart';
import 'package:pretty_affirmations/services/api_service.dart';
import 'package:pretty_affirmations/services/settings_service.dart';

class SelectCategoriesDialog extends StatefulWidget {
  final Function(List<String> unselectedTopics)? onApply;
  final List<MenuItem> menuItems;
  const SelectCategoriesDialog(
      {super.key, this.onApply, required this.menuItems});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => FluidDialog(
        rootPage: FluidDialogPage(
          alignment: Alignment.center,
          builder: (context) => FutureBuilder(
            future: getIt<ApiService>().getCategories(
                context.read<AppBase>().localeStr,
                filtered: false),
            builder: (context, snapshot) {
              return snapshot.asWidget(
                context: context,
                onWaiting: (context) => const Padding(
                  padding: EdgeInsets.all(5),
                  child: CircularProgressIndicator.adaptive(),
                ),
                onData: (context, data) => SelectCategoriesDialog(
                  menuItems: data,
                  onApply: (unselectedTopics) {
                    getIt<SettingsService>()
                        .setUnselectedTopics(unselectedTopics);
                    DialogNavigator.of(context).push(
                      FluidDialogPage(builder: (context) => const _ApplyInfo()),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  State<SelectCategoriesDialog> createState() => _SelectCategoriesDialogState();
}

class _SelectCategoriesDialogState extends State<SelectCategoriesDialog> {
  List<String> _unselectedTopics = [];

  @override
  void initState() {
    _unselectedTopics = getIt<SettingsService>().getUnselectedTopics();
    super.initState();
  }

  void _toggleUnselected(String id) {
    if (_unselectedTopics.contains(id)) {
      _unselectedTopics.remove(id);
    } else {
      _unselectedTopics.add(id);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      constraints: const BoxConstraints(minWidth: 340),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            S.of(context).selectCategory,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Divider(color: context.colors.primary, thickness: 2),
          Flexible(
            child: ListView.builder(
              itemCount: widget.menuItems.length,
              shrinkWrap: true,
              itemBuilder: (c, i) =>
                  _categoryItem(c, item: widget.menuItems[i]),
            ),
          ),
          const Gap(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                child: Text(S.of(context).cancel),
                onPressed: () => Navigator.pop(context),
              ),
              const Gap(15),
              ElevatedButton(
                child: Text(S.of(context).ok),
                onPressed: () => widget.onApply?.call(_unselectedTopics),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _categoryItem(
    BuildContext context, {
    required MenuItem item,
  }) {
    final bool isSelected = !_unselectedTopics.contains(item.id);
    return Column(
      children: [
        ListTile(
          onTap: () => _toggleUnselected(item.id),
          title: Text(
            item.name,
            style: const TextStyle(fontSize: 22),
          ),
          trailing: Icon(
            isSelected ? Icons.check_box : Icons.check_box_outline_blank,
            color: isSelected ? Colors.green : null,
            size: 28,
          ),
        ),
        const Divider()
      ],
    );
  }
}

class _ApplyInfo extends StatelessWidget {
  const _ApplyInfo();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Gap(15),
        CircleAvatar(
          radius: 30,
          backgroundColor: context.colors.tertiary,
          child:
              Icon(Icons.check, color: context.colors.primaryFixed, size: 50),
        ),
        Container(
          constraints: const BoxConstraints(minWidth: 340),
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(vertical: 14),
          child: Text(
            S.of(context).applyInfo,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22),
          ),
        ),
      ],
    );
  }
}
