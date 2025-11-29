import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../utils/extension/context_ext.dart';
import '../../generated/locale_keys.g.dart';

/// Service to handle location permission requests with proper prominent disclosure
/// according to Google Play policy requirements.
class LocationPermissionService {
  static bool _hasShownDisclosure = false;

  /// Requests location permission with prominent disclosure.
  /// Shows a disclosure dialog first, then requests system permission.
  static Future<LocationPermission> requestLocationPermission(
    BuildContext context, {
    bool forceShowDisclosure = false,
  }) async {
    // Check current permission status
    final currentPermission = await Geolocator.checkPermission();

    // If permission is already granted, return it
    if (currentPermission == LocationPermission.always ||
        currentPermission == LocationPermission.whileInUse) {
      return currentPermission;
    }

    // Show prominent disclosure if not shown yet or forced
    if (!_hasShownDisclosure || forceShowDisclosure) {
      // Ensure context is still mounted before showing dialog
      if (!context.mounted) {
        return LocationPermission.denied;
      }

      final shouldProceed = await _showProminentDisclosure(context);
      _hasShownDisclosure = true;

      if (!shouldProceed) {
        return LocationPermission.denied;
      }
    }

    // Request system permission after disclosure
    return await Geolocator.requestPermission();
  }

  /// Shows the prominent disclosure dialog about location data usage
  static Future<bool> _showProminentDisclosure(BuildContext context) async {
    // Check if context is still mounted before showing dialog
    if (!context.mounted) return false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          Symbols.location_on,
          size: 48,
          color: context.theme.colorScheme.primary,
        ),
        title: Text(
          LocaleKeys.locationDataDisclosureTitle.tr(),
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                LocaleKeys.locationDataDisclosureMessage.tr(),
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: context.theme.colorScheme.outline.withAlpha(100),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Symbols.privacy_tip,
                      size: 20,
                      color: context.theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your privacy is important. Location data is never shared with third parties.',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.theme.colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              LocaleKeys.notNow.tr(),
              style: TextStyle(
                color: context.theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Symbols.location_on),
            label: Text(LocaleKeys.allowLocationAccess.tr()),
          ),
        ],
        actionsAlignment: MainAxisAlignment.spaceBetween,
      ),
    );

    return result ?? false;
  }

  /// Resets the disclosure flag (useful for testing or when app settings change)
  static void resetDisclosureFlag() {
    _hasShownDisclosure = false;
  }

  /// Checks if location services are enabled and permission is granted
  static Future<bool> isLocationAvailable() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Shows a settings dialog if location is permanently denied
  static Future<void> showLocationSettingsDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocaleKeys.permissionTitle.tr()),
        content: Text(LocaleKeys.errorLocationPermanentDenied.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(LocaleKeys.cancel.tr()),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Geolocator.openAppSettings();
            },
            child: Text('Settings'),
          ),
        ],
      ),
    );
  }
}
