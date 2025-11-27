import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/features/kajian/presentation/components/search_items_bottom_sheet.dart';

import '../../../../core/utils/pair.dart';
import '../../../../generated/locale_keys.g.dart';

class ItemOnBottomSheet extends StatelessWidget {
  final String title;

  /// List of items with the
  /// First value as the display name
  /// Second value as ID
  final List<Pair<String, String>> items;
  final Pair<String, String>? selected;
  final Function(Pair<String, String>?) onSelected;
  final int? countShow;
  final bool isShowAllButton;
  final bool isMultipleSelect;
  final bool isLoading;

  const ItemOnBottomSheet({
    super.key,
    required this.title,
    required this.items,
    required this.selected,
    required this.onSelected,
    this.countShow,
    this.isShowAllButton = true,
    this.isMultipleSelect = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final showItems = items.take(countShow ?? 5).toList();
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                title,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (isShowAllButton && !isLoading) ...[
              TextButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    enableDrag: true,
                    isScrollControlled: true,
                    builder: (_) => DraggableScrollableSheet(
                      initialChildSize: 0.7,
                      minChildSize: 0.7,
                      maxChildSize: 0.9,
                      expand: false,
                      builder: (context, scrollController) {
                        return SearchItemBottomSheet(
                          title: title,
                          items: items,
                          selected: selected,
                          onSelected: onSelected,
                          scrollController: scrollController,
                          isMultipleSelect: isMultipleSelect,
                        );
                      },
                    ),
                  );
                },
                child: Text(
                  LocaleKeys.seeAll.tr(),
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.theme.colorScheme.primary,
                  ),
                ),
              ),
            ]
          ],
        ),
        isLoading
            ? const Center(
                child: LinearProgressIndicator(),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 0,
                children: isShowAllButton
                    ? showItems.map((e) => _buildItem(context, e)).toList()
                    : items.map((e) => _buildItem(context, e)).toList(),
              ),
      ],
    );
  }

  Widget _buildItem(BuildContext context, Pair<String, String> item) {
    return FilterChip(
      label: Text(item.first),
      backgroundColor: context.theme.colorScheme.surfaceContainer,
      selectedColor: context.theme.colorScheme.primaryContainer,
      elevation: 0,
      side: BorderSide(
        width: 0.5,
        color: context.theme.colorScheme.onSurface,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      showCheckmark: false,
      selected: selected?.second.split('|').contains(item.second) ?? false,
      onSelected: (value) {
        onSelected(item);
      },
    );
  }
}
