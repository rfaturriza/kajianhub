import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/core/error/failures.dart';

import '../../data/dataSources/local/tracking_settings_local_data_source.dart';
import '../entities/tracking_settings.codegen.dart';
import 'goals_notification_service.dart';

@injectable
class TrackingInitializationService {
  final TrackingSettingsLocalDataSource settingsDataSource;
  final GoalsNotificationService goalsNotificationService;

  const TrackingInitializationService({
    required this.settingsDataSource,
    required this.goalsNotificationService,
  });

  /// Initialize tracking settings and notifications on app startup
  Future<Either<Failure, Unit>> initializeTracking() async {
    try {
      // Check if settings exist, create defaults if not
      final settingsResult = await settingsDataSource.getTrackingSettings();

      late TrackingSettings settings;

      settingsResult.fold(
        (failure) {
          // Create default settings if none exist
          settings = TrackingSettings.defaultSettings();
        },
        (existingSettings) {
          if (existingSettings == null) {
            // Create default settings if none exist
            settings = TrackingSettings.defaultSettings();
          } else {
            settings = existingSettings;
            return right(unit); // Settings already exist, no need to save
          }
        },
      );

      // Save default settings if they were created
      final saveResult =
          await settingsDataSource.saveTrackingSettings(settings);
      if (saveResult.isLeft()) {
        return saveResult;
      }

      // Set up notifications with default settings
      final notificationResult =
          await goalsNotificationService.updateNotificationSettings();
      if (notificationResult.isLeft()) {
        // Don't fail initialization if notifications fail, just log it
        // return notificationResult;
      }

      return right(unit);
    } catch (e) {
      log(e.toString(),
          name: 'TrackingInitializationService.initializeTracking');
      return left(
        GeneralFailure(
          message: 'Sorry, failed to initialize tracking settings',
        ),
      );
    }
  }

  /// Reset tracking settings to defaults
  Future<Either<Failure, Unit>> resetToDefaults() async {
    try {
      final settings = TrackingSettings.defaultSettings();
      final saveResult =
          await settingsDataSource.saveTrackingSettings(settings);

      if (saveResult.isLeft()) {
        return saveResult;
      }

      // Update notifications with default settings
      final notificationResult =
          await goalsNotificationService.updateNotificationSettings();
      return notificationResult;
    } catch (e) {
      log(e.toString(), name: 'TrackingInitializationService.resetToDefaults');
      return left(
        GeneralFailure(message: 'Sorry, failed to reset tracking settings'),
      );
    }
  }
}
