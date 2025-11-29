import 'package:dartz/dartz.dart';
import 'package:quranku/core/error/failures.dart';

abstract class GoalsNotificationService {
  /// Schedule prayer reminder notifications (30 min after each prayer time)
  Future<Either<Failure, Unit>> schedulePrayerReminders();

  /// Schedule evening progress check-in notification
  Future<Either<Failure, Unit>> scheduleProgressCheckReminder();

  /// Cancel all tracking-related notifications
  Future<Either<Failure, Unit>> cancelAllTrackingNotifications();

  /// Update notification settings based on tracking settings
  Future<Either<Failure, Unit>> updateNotificationSettings();
}
