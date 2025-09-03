import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/geolocation.codegen.dart';
import '../entities/prayer_schedule_setting.codegen.dart';

abstract class PrayerAlarmRepository {
  Future<Either<Failure, PrayerScheduleSetting?>> getPrayerAlarmSchedule();

  Future<Either<Failure, Unit>> setPrayerAlarmSchedule(
    PrayerScheduleSetting? model,
  );

  Future<Either<Failure, GeoLocation?>> getPrayerLocationManual();

  Future<Either<Failure, Unit>> setPrayerLocationManual(
    GeoLocation? location,
  );

  Future<Either<Failure, Unit>> schedulePrayerAlarm();
  
  /// Schedules prayer alarms based on the current location
  /// This ensures notifications are updated when location changes
  Future<Either<Failure, Unit>> schedulePrayerAlarmWithLocation(GeoLocation location);
  
  /// Checks if the current location is significantly different from the stored location
  /// Returns true if notifications should be updated
  Future<Either<Failure, bool>> shouldUpdateNotifications(GeoLocation currentLocation);
}
