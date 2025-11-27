import 'package:dartz/dartz.dart';
import 'package:quranku/core/error/failures.dart';
import '../../../domain/entities/tracking_settings.codegen.dart';

abstract class TrackingSettingsLocalDataSource {
  /// Get tracking settings
  Future<Either<Failure, TrackingSettings?>> getTrackingSettings();

  /// Save tracking settings
  Future<Either<Failure, Unit>> saveTrackingSettings(TrackingSettings settings);

  /// Delete tracking settings (reset to defaults)
  Future<Either<Failure, Unit>> deleteTrackingSettings();
}
