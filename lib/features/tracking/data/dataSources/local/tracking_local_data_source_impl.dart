import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:hive_ce/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/core/constants/hive_constants.dart';
import 'package:quranku/core/error/failures.dart';
import '../../models/daily_tracking_model.codegen.dart';
import 'tracking_local_data_source.dart';
import 'tracking_settings_local_data_source.dart';

@LazySingleton(as: TrackingLocalDataSource)
class TrackingLocalDataSourceImpl implements TrackingLocalDataSource {
  static const String _trackingBox = HiveConst.dailyTrackingBox;
  final TrackingSettingsLocalDataSource _settingsDataSource;

  TrackingLocalDataSourceImpl(this._settingsDataSource);

  @override
  Future<Either<Failure, Unit>> saveDailyTracking(
      DailyTrackingModel tracking) async {
    try {
      var box = await Hive.openBox(_trackingBox);
      final updatedTracking = tracking.copyWith(
        updatedAt: DateTime.now(),
      );
      final jsonString = jsonEncode(updatedTracking.toJson());
      await box.put(tracking.date, jsonString);
      return right(unit);
    } catch (e) {
      return left(
        CacheFailure(
          message: 'Failed to save daily tracking: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, DailyTrackingModel?>> getDailyTracking(
      String date) async {
    try {
      var box = await Hive.openBox(_trackingBox);
      final jsonString = box.get(date);
      if (jsonString == null) return right(null);

      final json = jsonDecode(jsonString);
      final tracking = DailyTrackingModel.fromJson(json);
      return right(tracking);
    } catch (e) {
      return left(
        CacheFailure(
          message: 'Failed to get daily tracking: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, DailyTrackingModel>> getDailyTrackingOrCreate(
      String date) async {
    try {
      var box = await Hive.openBox(_trackingBox);
      final jsonString = box.get(date);

      if (jsonString != null) {
        final json = jsonDecode(jsonString);
        final tracking = DailyTrackingModel.fromJson(json);
        return right(tracking);
      }

      // Get default goals from settings
      int defaultAyahGoal = 30;
      int defaultMinuteGoal = 20;

      final settingsResult = await _settingsDataSource.getTrackingSettings();
      settingsResult.fold(
        (failure) {}, // Use defaults if settings fail to load
        (settings) {
          if (settings != null) {
            defaultAyahGoal = settings.defaultDailyAyahGoal;
            defaultMinuteGoal = settings.defaultDailyMinuteGoal;
          }
        },
      );

      // Create new tracking with settings-based goals
      final newTracking = DailyTrackingModel(
        date: date,
        dailyAyahGoal: defaultAyahGoal,
        dailyMinuteGoal: defaultMinuteGoal,
        createdAt: DateTime.now(),
      );

      // Save the new tracking
      final saveResult = await saveDailyTracking(newTracking);
      return saveResult.fold(
        (failure) => left(failure),
        (_) => right(newTracking),
      );
    } catch (e) {
      return left(
        CacheFailure(
          message: 'Failed to get or create daily tracking: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<DailyTrackingModel>>> getTrackingHistory() async {
    try {
      var box = await Hive.openBox(_trackingBox);
      final List<DailyTrackingModel> trackingList = [];

      for (var entry in box.toMap().entries) {
        try {
          final json = jsonDecode(entry.value);
          final tracking = DailyTrackingModel.fromJson(json);
          trackingList.add(tracking);
        } catch (e) {
          // Skip corrupted entries
          continue;
        }
      }

      // Sort by date descending (most recent first)
      trackingList.sort((a, b) => b.dateTime.compareTo(a.dateTime));

      return right(trackingList);
    } catch (e) {
      return left(
        CacheFailure(
          message: 'Failed to get tracking history: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteDailyTracking(String date) async {
    try {
      var box = await Hive.openBox(_trackingBox);
      await box.delete(date);
      return right(unit);
    } catch (e) {
      return left(
        CacheFailure(
          message: 'Failed to delete daily tracking: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getTrackingStatistics() async {
    try {
      final historyResult = await getTrackingHistory();
      return historyResult.fold(
        (failure) => left(failure),
        (history) {
          int totalPrayers = 0;
          int totalAyahs = 0;
          int totalMinutes = 0;
          int perfectDays = 0; // Days with all prayers completed
          int quranGoalDays = 0; // Days with quran goal achieved
          int currentPrayerStreak = 0;
          int currentQuranStreak = 0;
          int maxPrayerStreak = 0;
          int maxQuranStreak = 0;
          bool streakBroken = false;

          for (int i = 0; i < history.length; i++) {
            final tracking = history[i];
            totalPrayers += tracking.completedPrayers;
            totalAyahs += tracking.ayahsRead;
            totalMinutes += tracking.minutesRead;

            if (tracking.completedPrayers == 5) {
              perfectDays++;
              if (!streakBroken) {
                currentPrayerStreak++;
                maxPrayerStreak = currentPrayerStreak > maxPrayerStreak
                    ? currentPrayerStreak
                    : maxPrayerStreak;
              }
            } else {
              if (!streakBroken) {
                maxPrayerStreak = currentPrayerStreak > maxPrayerStreak
                    ? currentPrayerStreak
                    : maxPrayerStreak;
                currentPrayerStreak = 0;
              }
            }

            if (tracking.isQuranGoalAchieved) {
              quranGoalDays++;
              if (!streakBroken) {
                currentQuranStreak++;
                maxQuranStreak = currentQuranStreak > maxQuranStreak
                    ? currentQuranStreak
                    : maxQuranStreak;
              }
            } else {
              if (!streakBroken) {
                maxQuranStreak = currentQuranStreak > maxQuranStreak
                    ? currentQuranStreak
                    : maxQuranStreak;
                currentQuranStreak = 0;
              }
            }

            streakBroken =
                true; // Only count current streak for most recent consecutive days
          }

          return right({
            'totalDays': history.length,
            'totalPrayers': totalPrayers,
            'totalAyahs': totalAyahs,
            'totalMinutes': totalMinutes,
            'perfectPrayerDays': perfectDays,
            'quranGoalDays': quranGoalDays,
            'currentPrayerStreak': currentPrayerStreak,
            'currentQuranStreak': currentQuranStreak,
            'maxPrayerStreak': maxPrayerStreak,
            'maxQuranStreak': maxQuranStreak,
            'averagePrayersPerDay':
                history.isNotEmpty ? totalPrayers / history.length : 0.0,
            'averageAyahsPerDay':
                history.isNotEmpty ? totalAyahs / history.length : 0.0,
            'averageMinutesPerDay':
                history.isNotEmpty ? totalMinutes / history.length : 0.0,
          });
        },
      );
    } catch (e) {
      return left(
        CacheFailure(
          message: 'Failed to get tracking statistics: ${e.toString()}',
        ),
      );
    }
  }
}
