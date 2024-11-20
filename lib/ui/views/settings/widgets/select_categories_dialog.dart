import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/app/base.dart';
import 'package:pretty_affirmations/generated/l10n.dart';
import 'package:pretty_affirmations/models/menu_item.dart';
import 'package:pretty_affirmations/services/api_service.dart';
import 'package:pretty_affirmations/services/settings_service.dart';

class SelectCategoriesDialog extends StatefulWidget {
  final Function(List<String> unselectedTopics)? onApply;
  final List<MenuItem> menuItems;
  const SelectCategoriesDialog({
    super.key,
    this.onApply,
    required this.menuItems,
  });

  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => FluidDialog(
        rootPage: FluidDialogPage(
          alignment: Alignment.center,
          builder: (context) => _buildDialogContent(context),
        ),
      ),
    );
  }

  static Widget _buildDialogContent(BuildContext context) {
    return FutureBuilder(
      future: getIt<ApiService>().getCategories(
        context.read<AppBase>().localeStr,
        filtered: false,
      ),
      builder: (context, snapshot) {
        return snapshot.asWidget(
          context: context,
          onWaiting: (context) => const _LoadingIndicator(),
          onData: (context, data) => SelectCategoriesDialog(
            menuItems: data,
            onApply: (unselectedTopics) =>
                _handleApply(context, unselectedTopics),
          ),
        );
      },
    );
  }

  static void _handleApply(
      BuildContext context, List<String> unselectedTopics) {
    getIt<SettingsService>().setUnselectedTopics(unselectedTopics);
    DialogNavigator.of(context).push(
      FluidDialogPage(builder: (context) => const _ApplyInfo()),
    );
  }

  @override
  State<SelectCategoriesDialog> createState() => _SelectCategoriesDialogState();
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(5),
      child: CircularProgressIndicator.adaptive(),
    );
  }
}

class _SelectCategoriesDialogState extends State<SelectCategoriesDialog> {
  late List<String> _unselectedTopics;

  @override
  void initState() {
    super.initState();
    _unselectedTopics = getIt<SettingsService>().getUnselectedTopics();
  }

  void _toggleUnselected(String id) {
    setState(() {
      if (_unselectedTopics.contains(id)) {
        _unselectedTopics.remove(id);
      } else {
        _unselectedTopics.add(id);
      }
    });
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
          _buildCategoriesList(),
          const Gap(10),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Text(
          S.of(context).selectCategory,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Divider(color: context.colors.primary, thickness: 2),
      ],
    );
  }

  Widget _buildCategoriesList() {
    return Flexible(
      child: ListView.builder(
        itemCount: widget.menuItems.length,
        shrinkWrap: true,
        itemBuilder: (context, index) => _CategoryItem(
          item: widget.menuItems[index],
          isSelected: !_unselectedTopics.contains(widget.menuItems[index].id),
          onTap: () => _toggleUnselected(widget.menuItems[index].id),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(S.of(context).cancel),
        ),
        const Gap(15),
        ElevatedButton(
          onPressed: () => widget.onApply?.call(_unselectedTopics),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade100,
          ),
          child: Text(S.of(context).ok),
        ),
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final MenuItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          title: Text(
            item.name,
            style: const TextStyle(fontSize: 22),
          ),
          trailing: Icon(
            isSelected ? Icons.check_box : Icons.check_box_outline_blank,
            color: isSelected ? Colors.blueGrey.shade400 : null,
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
          child: Icon(
            Icons.check,
            color: context.colors.primaryFixed,
            size: 50,
          ),
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
