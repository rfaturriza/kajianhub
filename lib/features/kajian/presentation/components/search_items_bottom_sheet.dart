import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';

import '../../../../core/components/search_box.dart';
import '../../../../core/components/spacer.dart';
import '../../../../core/utils/pair.dart';
import '../../../../generated/locale_keys.g.dart';

class SearchItemBottomSheet extends StatefulWidget {
  final String title;
  final bool isMultipleSelect;

  /// List of items with the
  /// First value as the display NAME
  /// Second value as ID
  final List<Pair<String, String>> items;
  final Pair<String, String>? selected;
  final Function(Pair<String, String>?) onSelected;
  final ScrollController scrollController;

  const SearchItemBottomSheet({
    super.key,
    required this.title,
    required this.items,
    required this.selected,
    required this.onSelected,
    required this.scrollController,
    this.isMultipleSelect = true,
  });

  @override
  State<SearchItemBottomSheet> createState() => SearchItemBottomSheetState();
}

class SearchItemBottomSheetState extends State<SearchItemBottomSheet> {
  late List<Pair<String, String>> _filteredItems;
  final _selectedItems = ValueNotifier(<Pair<String, String>>[]);

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    for (final item in widget.selected?.second.split('|') ?? []) {
      _selectedItems.value.add(
        Pair(
          widget.items.firstWhere((e) => e.second == item).first,
          item,
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void onTap(Pair<String, String> item) {
      if (!widget.isMultipleSelect) {
        widget.onSelected(item);
        context.pop();
        return;
      }
      setState(() {
        if (_selectedItems.value
            .where((e) => e.second == item.second)
            .isNotEmpty) {
          _selectedItems.value.removeWhere(
            (e) => e.second == item.second,
          );
        } else {
          _selectedItems.value.add(item);
        }
      });
      widget.onSelected(
        _selectedItems.value.isEmpty
            ? null
            : Pair(
                _selectedItems.value.map((e) => e.first).toSet().join('|'),
                _selectedItems.value.map((e) => e.second).toSet().join('|'),
              ),
      );
    }

    return SafeArea(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  widget.title,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _filteredItems = widget.items;
                    _selectedItems.value.clear();
                  });
                  widget.onSelected(null);
                },
                child: Text(
                  LocaleKeys.reset.tr(),
                ),
              )
            ],
          ),
          SearchBox(
            initialValue: '',
            backgroundColor: context.theme.colorScheme.surfaceContainerHighest,
            hintText: LocaleKeys.search.tr(),
            onChanged: (value) {
              setState(() {
                _filteredItems = widget.items
                    .where((element) => element.first
                        .toLowerCase()
                        .contains(value.toLowerCase()))
                    .toList();
              });
            },
          ),
          const VSpacer(height: 10),
          ValueListenableBuilder(
            valueListenable: _selectedItems,
            builder: (context, value, child) {
              return Expanded(
                child: ListView.separated(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: _filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = _filteredItems[index];
                    return ListTile(
                      trailing: Checkbox(
                        value: _selectedItems.value
                            .where((e) => e.second == item.second)
                            .isNotEmpty,
                        onChanged: (_) {
                          onTap(item);
                        },
                      ),
                      title: Text(
                        item.first,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      selected: _selectedItems.value
                          .where((e) => e.second == item.second)
                          .isNotEmpty,
                      selectedTileColor:
                          context.theme.colorScheme.surfaceContainerHighest,
                      onTap: () {
                        onTap(item);
                      },
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const Divider();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
