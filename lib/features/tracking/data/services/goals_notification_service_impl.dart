import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/core/error/failures.dart';
import 'package:quranku/core/utils/local_notification.dart';
import 'package:quranku/features/shalat/domain/repositories/prayer_alarm_repository.dart';
import 'package:quranku/features/shalat/domain/entities/prayer_in_app.dart';
import 'package:quranku/generated/locale_keys.g.dart';

import '../../data/dataSources/local/tracking_settings_local_data_source.dart';
import '../../domain/services/goals_notification_service.dart';

@LazySingleton(as: GoalsNotificationService)
class GoalsNotificationServiceImpl implements GoalsNotificationService {
  final LocalNotification localNotification;
  final TrackingSettingsLocalDataSource settingsDataSource;
  final PrayerAlarmRepository prayerAlarmRepository;

  // Notification IDs for tracking reminders (starting from 1000 to avoid conflicts)
  static const int fajrReminderNotificationId = 1000;
  static const int dhuhrReminderNotificationId = 1001;
  static const int asrReminderNotificationId = 1002;
  static const int maghribReminderNotificationId = 1003;
  static const int ishaReminderNotificationId = 1004;
  static const int progressCheckReminderNotificationId = 1010;

  const GoalsNotificationServiceImpl({
    required this.localNotification,
    required this.settingsDataSource,
    required this.prayerAlarmRepository,
  });

  @override
  Future<Either<Failure, Unit>> schedulePrayerReminders() async {
    try {
      final settingsResult = await settingsDataSource.getTrackingSettings();
      if (settingsResult.isLeft()) {
        return left(settingsResult.fold((l) => l, (r) => throw Exception()));
      }

      final settings = settingsResult.fold((l) => null, (r) => r);
      if (settings == null || !settings.prayerRemindersEnabled) {
        // Cancel all prayer reminders if disabled
        await _cancelPrayerReminders();
        return right(unit);
      }

      // Get prayer schedule settings to calculate prayer times
      final prayerScheduleResult =
          await prayerAlarmRepository.getPrayerAlarmSchedule();
      if (prayerScheduleResult.isLeft()) {
        return left(
            prayerScheduleResult.fold((l) => l, (r) => throw Exception()));
      }

      final prayerSchedule = prayerScheduleResult.fold((l) => null, (r) => r);
      if (prayerSchedule == null) {
        log('Prayer schedule is null', name: 'GoalsNotificationServiceImpl.schedulePrayerReminders');
        return left(
          GeneralFailure(
            message:
                'Prayer schedule not found. Please set up prayer times first.',
          ),
        );
      }

      // Schedule notifications for each prayer, 30 minutes after prayer time
      final delayMinutes = settings.prayerReminderDelayMinutes;

      for (final alarm in prayerSchedule.alarms) {
        if (alarm.time == null || alarm.prayer == null) continue;

        final reminderTime = alarm.time!.add(Duration(minutes: delayMinutes));
        final timeOfDay = TimeOfDay.fromDateTime(reminderTime);

        String prayerName = _getPrayerDisplayName(alarm.prayer!);
        int notificationId = _getPrayerNotificationId(alarm.prayer!);

        await localNotification.scheduleDaily(
          id: notificationId,
          title: LocaleKeys.prayerTrackingReminderTitle.tr(),
          body: LocaleKeys.prayerTrackingReminderBody.tr(namedArgs: {
            'prayerName': prayerName,
          }),
          timeOfDay: timeOfDay,
        );
      }

      return right(unit);
    } catch (e) {
      log(e.toString(), name: 'GoalsNotificationServiceImpl.schedulePrayerReminders');
      return left(
        GeneralFailure(
          message: 'Sorry, failed to schedule prayer reminders'
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> scheduleProgressCheckReminder() async {
    try {
      final settingsResult = await settingsDataSource.getTrackingSettings();
      if (settingsResult.isLeft()) {
        return left(settingsResult.fold((l) => l, (r) => throw Exception()));
      }

      final settings = settingsResult.fold((l) => null, (r) => r);
      if (settings == null || !settings.progressCheckReminderEnabled) {
        // Cancel if disabled
        await localNotification.cancel(progressCheckReminderNotificationId);
        return right(unit);
      }

      await localNotification.scheduleDaily(
        id: progressCheckReminderNotificationId,
        title: LocaleKeys.progressCheckReminderTitle.tr(),
        body: LocaleKeys.progressCheckReminderBody.tr(),
        timeOfDay: settings.progressCheckReminderTimeOfDay,
      );

      return right(unit);
    } catch (e) {
      log(e.toString(), name: 'GoalsNotificationServiceImpl.scheduleProgressCheckReminder');
      return left(
        GeneralFailure(
          message: 'Sorry, failed to schedule progress check reminder'
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> cancelAllTrackingNotifications() async {
    try {
      await _cancelPrayerReminders();
      await localNotification.cancel(progressCheckReminderNotificationId);
      return right(unit);
    } catch (e) {
      log(e.toString(), name: 'GoalsNotificationServiceImpl.cancelAllTrackingNotifications');
      return left(
        GeneralFailure(
          message: 'Sorry, failed to cancel tracking notifications'
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> updateNotificationSettings() async {
    try {
      // Cancel existing notifications
      await cancelAllTrackingNotifications();

      // Reschedule based on current settings
      final prayerResult = await schedulePrayerReminders();
      if (prayerResult.isLeft()) {
        return prayerResult;
      }

      final progressResult = await scheduleProgressCheckReminder();
      if (progressResult.isLeft()) {
        return progressResult;
      }

      return right(unit);
    } catch (e) {
      log(e.toString(), name: 'GoalsNotificationServiceImpl.updateNotificationSettings');
      return left(
        GeneralFailure(
          message: 'Sorry, failed to update notification settings'
        ),
      );
    }
  }

  // Helper methods
  Future<void> _cancelPrayerReminders() async {
    await localNotification.cancel(fajrReminderNotificationId);
    await localNotification.cancel(dhuhrReminderNotificationId);
    await localNotification.cancel(asrReminderNotificationId);
    await localNotification.cancel(maghribReminderNotificationId);
    await localNotification.cancel(ishaReminderNotificationId);
  }

  String _getPrayerDisplayName(PrayerInApp prayer) {
    switch (prayer) {
      case PrayerInApp.subuh:
        return 'Fajr';
      case PrayerInApp.dzuhur:
        return 'Dhuhr';
      case PrayerInApp.ashar:
        return 'Asr';
      case PrayerInApp.maghrib:
        return 'Maghrib';
      case PrayerInApp.isya:
        return 'Isha';
      default:
        return prayer.name;
    }
  }

  int _getPrayerNotificationId(PrayerInApp prayer) {
    switch (prayer) {
      case PrayerInApp.subuh:
        return fajrReminderNotificationId;
      case PrayerInApp.dzuhur:
        return dhuhrReminderNotificationId;
      case PrayerInApp.ashar:
        return asrReminderNotificationId;
      case PrayerInApp.maghrib:
        return maghribReminderNotificationId;
      case PrayerInApp.isya:
        return ishaReminderNotificationId;
      default:
        return fajrReminderNotificationId; // fallback
    }
  }
}
