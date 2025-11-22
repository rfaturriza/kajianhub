import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:injectable/injectable.dart';
import '../entities/menu_item.codegen.dart';

@injectable
class MenuService {
  final FirebaseRemoteConfig _remoteConfig;

  MenuService(this._remoteConfig);

  /// Get primary menu items (Al-Qur'an, Kajian)
  Future<List<MenuItem>> getPrimaryMenuItems() async {
    try {
      await _remoteConfig.fetchAndActivate();
      final menuConfigString = _remoteConfig.getString('primary_menu_items');

      if (menuConfigString.isEmpty) {
        return _getDefaultPrimaryMenuItems();
      }

      final List<dynamic> menuJson = json.decode(menuConfigString);
      final menuItems = menuJson
          .map((item) => MenuItem.fromJson(item as Map<String, dynamic>))
          .where((item) => item.isEnabled && item.isPrimary)
          .toList();

      // Sort by order
      menuItems.sort((a, b) => a.order.compareTo(b.order));

      return menuItems;
    } catch (e) {
      // Return default items if remote config fails
      return _getDefaultPrimaryMenuItems();
    }
  }

  /// Get secondary menu items (Ustadz AI, Shalat, etc.)
  Future<List<MenuItem>> getSecondaryMenuItems() async {
    try {
      await _remoteConfig.fetchAndActivate();
      final menuConfigString = _remoteConfig.getString('secondary_menu_items');

      if (menuConfigString.isEmpty) {
        return _getDefaultSecondaryMenuItems();
      }

      final List<dynamic> menuJson = json.decode(menuConfigString);
      final menuItems = menuJson
          .map((item) => MenuItem.fromJson(item as Map<String, dynamic>))
          .where((item) => item.isEnabled && !item.isPrimary)
          .toList();

      // Sort by order
      menuItems.sort((a, b) => a.order.compareTo(b.order));

      return menuItems;
    } catch (e) {
      // Return default items if remote config fails
      return _getDefaultSecondaryMenuItems();
    }
  }

  /// Get all menu items
  Future<List<MenuItem>> getAllMenuItems() async {
    try {
      await _remoteConfig.fetchAndActivate();
      final menuConfigString = _remoteConfig.getString('all_menu_items');

      if (menuConfigString.isEmpty) {
        // Fallback: combine primary and secondary
        final primary = await getPrimaryMenuItems();
        final secondary = await getSecondaryMenuItems();
        return [...primary, ...secondary];
      }

      final List<dynamic> menuJson = json.decode(menuConfigString);
      final menuItems = menuJson
          .map((item) => MenuItem.fromJson(item as Map<String, dynamic>))
          .where((item) => item.isEnabled)
          .toList();

      // Sort by order
      menuItems.sort((a, b) => a.order.compareTo(b.order));

      return menuItems;
    } catch (e) {
      // Return combined default items if remote config fails
      final primary = _getDefaultPrimaryMenuItems();
      final secondary = _getDefaultSecondaryMenuItems();
      return [...primary, ...secondary];
    }
  }

  List<MenuItem> _getDefaultPrimaryMenuItems() {
    return [
      const MenuItem(
        id: 'quran',
        label: 'Al-Qur\'an',
        labelKey: 'quran',
        iconName: 'menu_book_rounded',
        colorHex: '#2D5016',
        route: '/quran',
        order: 1,
        isPrimary: true,
      ),
      const MenuItem(
        id: 'kajian',
        label: 'Kajian',
        labelKey: 'kajian',
        iconName: 'play_circle',
        colorHex: '#D4AF37',
        route: '/kajian',
        order: 2,
        isPrimary: true,
      ),
    ];
  }

  List<MenuItem> _getDefaultSecondaryMenuItems() {
    return [
      const MenuItem(
        id: 'ustadz_ai',
        label: 'Ustadz AI',
        labelKey: 'ustadz_ai',
        iconName: 'smart_toy',
        colorHex: '#8B4513',
        route: '/ustadz-ai',
        order: 1,
        isPrimary: false,
      ),
      const MenuItem(
        id: 'shalat',
        label: 'Shalat',
        labelKey: 'shalat',
        iconName: 'prayer',
        colorHex: '#4682B4',
        route: '/shalat',
        order: 2,
        isPrimary: false,
      ),
      const MenuItem(
        id: 'masjid',
        label: 'Masjid',
        labelKey: 'masjid',
        iconName: 'mosque',
        colorHex: '#DC143C',
        route: '/masjid',
        order: 3,
        isPrimary: false,
      ),
      const MenuItem(
        id: 'ustadz',
        label: 'Ustadz',
        labelKey: 'ustadz',
        iconName: 'person',
        colorHex: '#8B4513',
        route: '/ustadz',
        order: 4,
        isPrimary: false,
      ),
      const MenuItem(
        id: 'doa',
        label: 'Doa',
        labelKey: 'doa',
        iconName: 'favorite',
        colorHex: '#9932CC',
        route: '/doa',
        order: 5,
        isPrimary: false,
      ),
      const MenuItem(
        id: 'buletin',
        label: 'Buletin',
        labelKey: 'buletin',
        iconName: 'article',
        colorHex: '#FF6347',
        route: '/buletin',
        order: 6,
        isPrimary: false,
      ),
    ];
  }
}
