import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/injection.dart';

import '../../../../../core/components/spacer.dart';
import '../../../../../core/route/root_router.dart';
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
  List<MenuItem> _primaryMenuItems = [];
  List<MenuItem> _secondaryMenuItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  Future<void> _loadMenuItems() async {
    try {
      final primary = await _menuService.getPrimaryMenuItems();
      final secondary = await _menuService.getSecondaryMenuItems();

      if (mounted) {
        setState(() {
          _primaryMenuItems = primary;
          _secondaryMenuItems = secondary;
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
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Jelajahi Islam",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Jelajahi Islam",
            style: context.theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const VSpacer(height: 10),

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
                  children: _primaryMenuItems.map((menuItem) {
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
                  }).toList(),
                );
              },
            ),
            const VSpacer(height: 16),
          ],

          // Secondary menu items (responsive grid)
          if (_secondaryMenuItems.isNotEmpty)
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
                  children: _secondaryMenuItems.map((menuItem) {
                    return SizedBox(
                      width: itemWidth,
                      child: CategoryMenuItem(
                        width: itemWidth,
                        icon: menuItem.icon,
                        label: menuItem.localizedLabel,
                        color: menuItem.color,
                        badgeText: menuItem.badge,
                        badgeColor: menuItem.badgeColorHex != null
                            ? Color(int.parse('0xff${menuItem.badgeColorHex}'))
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
        ],
      ),
    );
  }

  void _handleMenuItemTap(BuildContext context, MenuItem menuItem) {
    // Handle navigation based on the menu item route
    switch (menuItem.route) {
      case '/quran':
      case '/surah':
      case '/juz':
        context.pushNamed(RootRouter.quran.name);
        break;
      case '/kajian':
        context.pushNamed(RootRouter.kajianRoute.name);
        break;
      case '/ustadz-ai':
      case '/ustad-ai':
        context.pushNamed(RootRouter.ustadAiRoute.name);
        break;
      case '/shalat':
      case '/prayer-time':
        context.pushNamed(RootRouter.prayerTimeRoute.name);
        break;
      case '/masjid':
      case '/study-location':
        context.pushNamed(RootRouter.studyLocationRoute.name);
        break;
      case '/ustadz':
        context.pushNamed(RootRouter.ustadzRoute.name);
        break;
      case '/doa':
      case '/pray':
        context.pushNamed(RootRouter.prayRoute.name);
        break;
      case '/buletin':
        context.pushNamed(RootRouter.buletinRoute.name);
        break;
      case '/qibla':
        context.pushNamed(RootRouter.qiblaRoute.name);
        break;
      case '/donation':
        context.pushNamed(RootRouter.donationRoute.name);
        break;
      case '/profile':
        context.pushNamed(RootRouter.profileRoute.name);
        break;
      default:
        // Default action or show not implemented message
        context.showInfoToast('${menuItem.label} akan segera hadir');
    }
  }
}
