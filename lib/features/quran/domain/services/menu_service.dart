import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:injectable/injectable.dart';
import '../entities/menu_item.codegen.dart';

@injectable
class MenuService {
  final FirebaseRemoteConfig _remoteConfig;
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  MenuService(this._remoteConfig);

  /// Get primary menu items (Al-Qur'an, Kajian) with retry mechanism
  Future<List<MenuItem>> getPrimaryMenuItems() async {
    return await _fetchMenuItemsWithRetry(
      'primary_menu_items',
      isPrimary: true,
    );
  }

  /// Get secondary menu items (Ustadz AI, Shalat, etc.) with retry mechanism
  Future<List<MenuItem>> getSecondaryMenuItems() async {
    return await _fetchMenuItemsWithRetry(
      'secondary_menu_items',
      isPrimary: false,
    );
  }

  /// Get all menu items with retry mechanism
  Future<List<MenuItem>> getAllMenuItems() async {
    return await _fetchMenuItemsWithRetry('all_menu_items');
  }

  /// Fetch menu items with retry logic
  Future<List<MenuItem>> _fetchMenuItemsWithRetry(String configKey,
      {bool? isPrimary}) async {
    Exception? lastException;

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        await _remoteConfig.fetchAndActivate();
        final menuConfigString = _remoteConfig.getString(configKey);

        if (menuConfigString.isEmpty) {
          throw Exception(
            'Remote config returned empty string for key: $configKey',
          );
        }

        final List<dynamic> menuJson = json.decode(menuConfigString);
        List<MenuItem> menuItems = menuJson
            .map((item) => MenuItem.fromJson(item as Map<String, dynamic>))
            .where((item) => item.isEnabled)
            .toList();

        // Apply primary/secondary filter if specified
        if (isPrimary != null) {
          menuItems = menuItems
              .where(
                (item) => item.isPrimary == isPrimary,
              )
              .toList();
        }

        // Sort by order
        menuItems.sort((a, b) => a.order.compareTo(b.order));

        if (menuItems.isEmpty) {
          throw Exception('No enabled menu items found for key: $configKey');
        }

        return menuItems;
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());

        if (attempt < maxRetries - 1) {
          // Wait before retrying (exponential backoff)
          await Future.delayed(retryDelay * (attempt + 1));
        }
      }
    }

    // If all retries failed, throw the last exception
    throw Exception(
      'Failed to fetch menu items after $maxRetries attempts. Last error: ${lastException?.toString()}',
    );
  }
}
