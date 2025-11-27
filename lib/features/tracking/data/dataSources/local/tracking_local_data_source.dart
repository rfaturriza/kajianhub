import 'package:dartz/dartz.dart';
import 'package:quranku/core/error/failures.dart';
import '../../models/daily_tracking_model.codegen.dart';

abstract class TrackingLocalDataSource {
  /// Save or update daily tracking data
  Future<Either<Failure, Unit>> saveDailyTracking(DailyTrackingModel tracking);

  /// Get tracking data for specific date
  Future<Either<Failure, DailyTrackingModel?>> getDailyTracking(String date);

  /// Get tracking data for specific date, create with user settings if not found
  Future<Either<Failure, DailyTrackingModel>> getDailyTrackingOrCreate(
      String date);

  /// Get all tracking history (sorted by date descending)
  Future<Either<Failure, List<DailyTrackingModel>>> getTrackingHistory();

  /// Delete tracking data for specific date
  Future<Either<Failure, Unit>> deleteDailyTracking(String date);

  /// Get tracking statistics (streak, total prayers, total ayahs, etc.)
  Future<Either<Failure, Map<String, dynamic>>> getTrackingStatistics();
}
