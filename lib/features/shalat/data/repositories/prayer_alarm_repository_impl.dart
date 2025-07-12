import 'package:adhan/adhan.dart';
import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/core/error/failures.dart';
import 'package:quranku/core/utils/extension/dartz_ext.dart';
import 'package:quranku/core/utils/extension/string_ext.dart';
import 'package:quranku/features/shalat/data/models/prayer_schedule_setting_model.codegen.dart';
import 'package:quranku/features/shalat/domain/entities/geolocation.codegen.dart';
import 'package:quranku/features/shalat/domain/entities/prayer_schedule_setting.codegen.dart';
import 'package:quranku/features/shalat/domain/entities/prayer_in_app.dart';
import 'package:quranku/features/shalat/presentation/helper/location_helper.dart';
import 'package:quranku/generated/locale_keys.g.dart';

import '../../../../core/utils/local_notification.dart';
import '../../domain/repositories/prayer_alarm_repository.dart';
import '../dataSources/local/shalat_local_data_source.dart';

@LazySingleton(as: PrayerAlarmRepository)
class PrayerAlarmRepositoryImpl implements PrayerAlarmRepository {
  final ShalatLocalDataSource localDataSource;
  final LocalNotification localNotification;

  const PrayerAlarmRepositoryImpl(
      {required this.localDataSource, required this.localNotification});

  @override
  Future<Either<Failure, PrayerScheduleSetting?>>
      getPrayerAlarmSchedule() async {
    final result = await localDataSource.getPrayerScheduleSetting();
    return result.fold((error) => left(error), (r) => right(r?.toEntity()));
  }

  @override
  Future<Either<Failure, GeoLocation?>> getPrayerLocationManual() async {
    final result = await localDataSource.getPrayerLocationManual();
    return result;
  }

  @override
  Future<Either<Failure, Unit>> setPrayerAlarmSchedule(
    PrayerScheduleSetting? model,
  ) async {
    final result = await localDataSource.setPrayerScheduleSetting(
      PrayerScheduleSettingModel.fromEntity(model),
    );
    return result;
  }

  @override
  Future<Either<Failure, Unit>> setPrayerLocationManual(
    GeoLocation? location,
  ) async {
    final result = await localDataSource.setPrayerLocationManual(location);
    return result.fold((error) => left(error), (r) => right(r));
  }

  @override
  Future<Either<Failure, Unit>> schedulePrayerAlarm() async {
    final result = await localDataSource.getPrayerScheduleSetting();
    if (result.isLeft()) {
      return left(result.asLeft());
    }
    final entity = result.asRight()?.toEntity();
    final alarms = entity?.alarms;

    alarms?.forEach((element) async {
      if (element.time == null) return;
      final hour = TimeOfDay.fromDateTime(element.time!).hour;
      final minute = TimeOfDay.fromDateTime(element.time!).minute;
      await localNotification.scheduleDaily(
        id: element.prayer?.index ?? 0,
        title: LocaleKeys.notificationPrayerTitle.tr(namedArgs: {
          'prayer': element.prayer?.name.capitalizeEveryWord() ?? '',
          'time': '$hour:$minute',
        }),
        body: LocaleKeys.notificationPrayerDescription.tr(
          namedArgs: {
            'location': entity?.location ?? '',
          },
        ),
        timeOfDay: TimeOfDay.fromDateTime(element.time!),
      );
    });
    return right(unit);
  }

  @override
  Future<Either<Failure, Unit>> schedulePrayerAlarmWithLocation(
      GeoLocation location) async {
    try {
      // Get current prayer settings
      final settingsResult = await localDataSource.getPrayerScheduleSetting();
      if (settingsResult.isLeft()) {
        return left(settingsResult.asLeft());
      }

      final currentSettings = settingsResult.asRight()?.toEntity();
      if (currentSettings == null) {
        return left(GeneralFailure(message: 'Prayer settings not found'));
      }

      // Calculate prayer times based on the new location
      final coordinate = Coordinates(
        location.coordinate?.lat ?? 0,
        location.coordinate?.lon ?? 0,
        validate: true,
      );

      // Use the same calculation method and madhab from current settings
      final params = CalculationMethod.values
          .firstWhere(
            (e) => e.name == currentSettings.calculationMethod.name,
            orElse: () => CalculationMethod.umm_al_qura,
          )
          .getParameters();
      params.madhab = currentSettings.madhab;

      // Calculate prayer times for today
      final prayerTimes = PrayerTimes.today(coordinate, params);

      // Update alarm times based on the new prayer times
      final updatedAlarms = currentSettings.alarms.map((alarm) {
        if (alarm.alarmType == 3 || alarm.prayer == null) {
          return alarm;
        }

        // Get the new time for this prayer based on the new location
        DateTime? newTime;
        switch (alarm.prayer) {
          case PrayerInApp.imsak:
            // Imsak is typically 10 minutes before Fajr
            final fajrTime = prayerTimes.fajr;
            newTime = fajrTime.subtract(const Duration(minutes: 10));
            break;
          case PrayerInApp.subuh:
            newTime = prayerTimes.fajr;
            break;
          case PrayerInApp.syuruq:
            newTime = prayerTimes.sunrise;
            break;
          case PrayerInApp.dhuha:
            // Dhuha is typically 15-20 minutes after sunrise
            final sunriseTime = prayerTimes.sunrise;
            newTime = sunriseTime.add(const Duration(minutes: 15));
            break;
          case PrayerInApp.dzuhur:
            newTime = prayerTimes.dhuhr;
            break;
          case PrayerInApp.ashar:
            newTime = prayerTimes.asr;
            break;
          case PrayerInApp.maghrib:
            newTime = prayerTimes.maghrib;
            break;
          case PrayerInApp.isya:
            newTime = prayerTimes.isha;
            break;
          default:
            newTime = alarm.time;
        }

        if (alarm.reminderEnabled && newTime != null) {
          // Adjust the time for reminders if enabled
          newTime = newTime.subtract(Duration(minutes: alarm.reminderTime));
        }

        // Return updated alarm with new time
        return alarm.copyWith(time: newTime);
      }).toList();

      // Create updated settings with new location and alarm times
      final updatedSettings = currentSettings.copyWith(
        alarms: updatedAlarms,
        location: location.place,
      );

      // Save updated settings
      final saveResult = await localDataSource.setPrayerScheduleSetting(
        PrayerScheduleSettingModel.fromEntity(updatedSettings),
      );

      if (saveResult.isLeft()) {
        return left(saveResult.asLeft());
      }

      // Schedule notifications with the updated times
      for (final element in updatedSettings.alarms) {
        if (element.time == null) continue;
        if (element.alarmType == 3) {
          await localNotification.cancel(element.prayer?.index ?? 0);
          continue;
        }

        final hour = TimeOfDay.fromDateTime(element.time!).hour;
        final minute = TimeOfDay.fromDateTime(element.time!).minute;

        // Cancel existing notification before scheduling a new one
        await localNotification.cancel(element.prayer?.index ?? 0);

        String androidSound = 'adzan_general';
        String iosSound = 'adzan_general.wav';

        if (element.reminderEnabled) {
          // Schedule reminder notification
          await localNotification.scheduleDaily(
            id: element.prayer?.index ?? 0,
            title: LocaleKeys.notificationReminderPrayerTitle.tr(namedArgs: {
              'ReminderTime': element.reminderTime.toString(),
              'prayer': element.prayer?.name.capitalizeEveryWord() ?? '',
              'time': '$hour:$minute',
            }),
            body: LocaleKeys.notificationPrayerDescription.tr(
              namedArgs: {
                'location': updatedSettings.location,
              },
            ),
            timeOfDay: TimeOfDay.fromDateTime(element.time!),
            mute: element.alarmType == 2, // silent,
            androidSound: element.alarmType == 0 ? androidSound : null,
            iosSound: element.alarmType == 0 ? iosSound : null,
          );
        } else {
          await localNotification.scheduleDaily(
            id: element.prayer?.index ?? 0,
            title: LocaleKeys.notificationPrayerTitle.tr(namedArgs: {
              'prayer': element.prayer?.name.capitalizeEveryWord() ?? '',
              'time': '$hour:$minute',
            }),
            body: LocaleKeys.notificationPrayerDescription.tr(
              namedArgs: {
                'location': updatedSettings.location,
              },
            ),
            timeOfDay: TimeOfDay.fromDateTime(element.time!),
            mute: element.alarmType == 2, // silent,
            androidSound: element.alarmType == 0 ? androidSound : null,
            iosSound: element.alarmType == 0 ? iosSound : null,
          );
        }
      }

      return right(unit);
    } catch (e) {
      return left(GeneralFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> shouldUpdateNotifications(
      GeoLocation currentLocation) async {
    try {
      // Get the stored location
      final storedLocationResult =
          await localDataSource.getPrayerLocationManual();
      final storedLocation = storedLocationResult.fold(
        (failure) => null,
        (location) => location,
      );

      // Check if the locations are significantly different
      final shouldUpdate = LocationHelper.isLocationSignificantlyDifferent(
        storedLocation,
        currentLocation,
      );

      // If we should update, store the new location
      if (shouldUpdate) {
        await localDataSource.setPrayerLocationManual(currentLocation);
      }

      return right(shouldUpdate);
    } catch (e) {
      return left(GeneralFailure(message: e.toString()));
    }
  }
}
