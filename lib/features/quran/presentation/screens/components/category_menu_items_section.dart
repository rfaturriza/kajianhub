import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:quranku/core/components/error_screen.dart';
import 'package:quranku/core/components/search_box.dart';
import 'package:quranku/core/components/spacer.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/generated/locale_keys.g.dart';
import 'package:quranku/injection.dart';
import 'package:shimmer/shimmer.dart';

import '../../../domain/entities/menu_item.codegen.dart';
import '../../../domain/services/menu_service.dart';
import 'category_menu_item.dart';

class CategoryMenuItemsSection extends StatefulWidget {
  const CategoryMenuItemsSection({super.key});

  @override
  State<CategoryMenuItemsSection> createState() =>
      _CategoryMenuItemsSectionState();
}

class _CategoryMenuItemsSectionState extends State<CategoryMenuItemsSection> {
  final MenuService _menuService = sl<MenuService>();
  final TextEditingController _searchController = TextEditingController();
  List<MenuItem> _primaryMenuItems = [];
  List<MenuItem> _secondaryMenuItems = [];
  List<MenuItem> _filteredSecondaryMenuItems = [];
  bool _isLoading = true;
  static const int maxSecondaryMenuItems = 7;

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMenuItems() async {
    try {
      final primary = await _menuService.getPrimaryMenuItems();
      final secondary = await _menuService.getSecondaryMenuItems();

      if (mounted) {
        setState(() {
          _primaryMenuItems = primary;
          _secondaryMenuItems = secondary;
          _filteredSecondaryMenuItems = primary + secondary;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.exploreIslam.tr(),
            style: context.theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const VSpacer(height: 16),

          // Primary menu items (2 items per row)
          if (_primaryMenuItems.isNotEmpty) ...[
            LayoutBuilder(
              builder: (context, constraints) {
                const itemsPerRow = 2;
                final spacing = 16;
                final availableWidth =
                    constraints.maxWidth - (spacing * (itemsPerRow - 1));
                final itemWidth = availableWidth / itemsPerRow;

                return Wrap(
                  spacing: spacing.toDouble(),
                  runSpacing: 16,
                  children: [
                    if (_isLoading) ...[
                      Shimmer.fromColors(
                        baseColor:
                            context.theme.colorScheme.surfaceContainerHighest,
                        highlightColor: context.theme.colorScheme.surface,
                        child: Column(
                          children: [
                            Container(
                              width: itemWidth,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: itemWidth * 0.6,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    ..._primaryMenuItems.map((menuItem) {
                      return CategoryMenuItem(
                        width: itemWidth,
                        icon: menuItem.icon,
                        label: menuItem.localizedLabel,
                        labelInside: true,
                        color: menuItem.color,
                        onTap: () {
                          // Handle navigation based on route
                          _handleMenuItemTap(context, menuItem);
                        },
                      );
                    }),
                  ],
                );
              },
            ),
            const VSpacer(height: 16),
          ],

          // Secondary menu items (responsive grid)
          if (_secondaryMenuItems.isNotEmpty) ...[
            LayoutBuilder(
              builder: (context, constraints) {
                final itemsPerRow = () {
                  switch (true) {
                    case var _ when constraints.maxWidth > 600:
                      return 7;
                    case var _ when constraints.maxWidth > 400:
                      return 5;
                    default:
                      return 4;
                  }
                }();

                final spacing = 16;
                final availableWidth =
                    constraints.maxWidth - (spacing * (itemsPerRow - 1));
                final itemWidth = availableWidth / itemsPerRow;

                return Wrap(
                  spacing: spacing.toDouble(),
                  runSpacing: 16,
                  children: [
                    if (_isLoading) ...[
                      for (int i = 0; i < itemsPerRow; i++)
                        Shimmer.fromColors(
                          baseColor:
                              context.theme.colorScheme.surfaceContainerHighest,
                          highlightColor: context.theme.colorScheme.surface,
                          child: Column(
                            children: [
                              Container(
                                width: itemWidth,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: itemWidth * 0.6,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                    // Show first 7 secondary menu items
                    ..._secondaryMenuItems
                        .take(maxSecondaryMenuItems)
                        .map((menuItem) {
                      return SizedBox(
                        width: itemWidth,
                        child: CategoryMenuItem(
                          isShimmer: menuItem.id == "ustadz_ai",
                          width: itemWidth,
                          icon: menuItem.icon,
                          label: menuItem.localizedLabel,
                          color: menuItem.color,
                          badgeText: menuItem.badge,
                          badgeColor: menuItem.badgeColorHex != null
                              ? Color(
                                  int.parse('0xff${menuItem.badgeColorHex}'))
                              : null,
                          onTap: () {
                            _handleMenuItemTap(context, menuItem);
                          },
                        ),
                      );
                    }),
                    // Show "More" icon if there are more than 7 items
                    if (_secondaryMenuItems.length > maxSecondaryMenuItems)
                      SizedBox(
                        width: itemWidth,
                        child: CategoryMenuItem(
                          width: itemWidth,
                          icon: Symbols.more_horiz,
                          label: LocaleKeys.more.tr(),
                          color: context.theme.colorScheme.onTertiaryContainer,
                          onTap: () {
                            _showAllMenuItemsBottomSheet(context);
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ],

          if ((_primaryMenuItems.isEmpty || _secondaryMenuItems.isEmpty) &&
              !_isLoading) ...[
            ErrorScreen(
              message: LocaleKeys.defaultErrorMessage.tr(),
              onRefresh: _loadMenuItems,
            ),
          ],
        ],
      ),
    );
  }

  void _showAllMenuItemsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: false,
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: context.theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // Handle bar
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.onSurfaceVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Title
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          LocaleKeys.exploreIslam.tr(),
                          style: context.theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // Search field
                    SearchBox(
                      initialValue: _searchController.text,
                      hintText: LocaleKeys.search.tr(),
                      onChanged: (value) {
                        setModalState(() {
                          _filteredSecondaryMenuItems = _secondaryMenuItems
                              .where((item) => item.localizedLabel
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                      onClear: () {
                        _searchController.clear();
                        setModalState(() {
                          _filteredSecondaryMenuItems = _secondaryMenuItems;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Menu items grid
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            const itemsPerRow = 4;
                            const spacing = 16;
                            final availableWidth = constraints.maxWidth -
                                (spacing * (itemsPerRow - 1));
                            final itemWidth = availableWidth / itemsPerRow;

                            return Wrap(
                              spacing: spacing.toDouble(),
                              runSpacing: 16,
                              children:
                                  _filteredSecondaryMenuItems.map((menuItem) {
                                return SizedBox(
                                  width: itemWidth,
                                  child: CategoryMenuItem(
                                    isShimmer: menuItem.id == "ustadz_ai",
                                    width: itemWidth,
                                    icon: menuItem.icon,
                                    label: menuItem.localizedLabel,
                                    color: menuItem.color,
                                    badgeText: menuItem.badge,
                                    badgeColor: menuItem.badgeColorHex != null
                                        ? Color(
                                            int.parse(
                                              '0xff${menuItem.badgeColorHex}',
                                            ),
                                          )
                                        : null,
                                    onTap: () {
                                      _handleMenuItemTap(context, menuItem);
                                    },
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                    ),

                    // Bottom padding for safe area
                    SizedBox(height: MediaQuery.of(context).padding.bottom),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _handleMenuItemTap(BuildContext context, MenuItem menuItem) {
    try {
      context.push(menuItem.route);
    } catch (e) {
      context.showInfoToast('${menuItem.label} akan segera hadir');
    }
  }
}
