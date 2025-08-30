import 'package:adhan/adhan.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'prayer_in_app.dart';

part 'prayer_schedule_setting.codegen.freezed.dart';

@freezed
abstract class PrayerScheduleSetting with _$PrayerScheduleSetting {
  const factory PrayerScheduleSetting({
    @Default([]) List<PrayerAlarm> alarms,
    @Default(CalculationMethod.egyptian) CalculationMethod calculationMethod,
    @Default(Madhab.shafi) Madhab madhab,
    @Default('') String location,
  }) = _PrayerScheduleSetting;
}

@freezed
abstract class PrayerAlarm with _$PrayerAlarm {
  const factory PrayerAlarm({
    DateTime? time,
    PrayerInApp? prayer,
    @Default(3) int alarmType,
    @Default(0) int reminderTime,
    @Default(false) bool reminderEnabled,
  }) = _PrayerAlarm;
}
