import 'package:adhan/adhan.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce/hive.dart';

import '../../../../core/constants/hive_constants.dart';
import '../../domain/entities/prayer_in_app.dart';
import '../../domain/entities/prayer_schedule_setting.codegen.dart';

part 'prayer_schedule_setting_model.codegen.freezed.dart';
part 'prayer_schedule_setting_model.codegen.g.dart';

@freezed
@HiveType(typeId: HiveTypeConst.prayerScheduleSettingModel)
abstract class PrayerScheduleSettingModel with _$PrayerScheduleSettingModel {
  const factory PrayerScheduleSettingModel({
    @HiveField(0) @Default([]) List<PrayerAlarmModel> alarms,
    @HiveField(1) @Default('egyptian') String calculationMethod,
    @HiveField(2) @Default('shafi') String madhab,
    @HiveField(3) @Default('') String location,
  }) = _PrayerScheduleSettingModel;

  const PrayerScheduleSettingModel._();

  factory PrayerScheduleSettingModel.fromJson(Map<String, dynamic> json) =>
      _$PrayerScheduleSettingModelFromJson(json);

  factory PrayerScheduleSettingModel.fromEntity(PrayerScheduleSetting? entity) {
    return PrayerScheduleSettingModel(
      calculationMethod:
          entity?.calculationMethod.name ?? CalculationMethod.egyptian.name,
      location: entity?.location ?? '',
      madhab: entity?.madhab.name ?? Madhab.shafi.name,
      alarms: entity?.alarms
              .map((e) => PrayerAlarmModel.fromEntity(
                    e,
                  ))
              .toList() ??
          [],
    );
  }

  PrayerScheduleSetting toEntity() {
    return PrayerScheduleSetting(
      alarms: alarms.map((e) => e.toEntity()).toList(),
      location: location,
      calculationMethod: CalculationMethod.values.firstWhere(
        (element) => element.name == calculationMethod,
      ),
      madhab: Madhab.values.firstWhere(
        (element) => element.name == madhab,
      ),
    );
  }
}

@freezed
@HiveType(typeId: HiveTypeConst.prayerAlarmModel)
abstract class PrayerAlarmModel with _$PrayerAlarmModel {
  const factory PrayerAlarmModel({
    @HiveField(0) DateTime? time,
    @HiveField(1) String? prayer,
    @HiveField(3) @Default(3) int alarmType,
    @HiveField(4) @Default(0) int reminderTime,
    @HiveField(5) @Default(false) bool reminderEnabled,
  }) = _PrayerAlarmModel;

  const PrayerAlarmModel._();

  factory PrayerAlarmModel.fromJson(Map<String, dynamic> json) =>
      _$PrayerAlarmModelFromJson(json);

  factory PrayerAlarmModel.fromEntity(PrayerAlarm? entity) {
    return PrayerAlarmModel(
      time: entity?.time,
      prayer: entity?.prayer?.name,
      alarmType: entity?.alarmType ?? 3,
      reminderTime: entity?.reminderTime ?? 0,
      reminderEnabled: entity?.reminderEnabled ?? false,
    );
  }

  PrayerAlarm toEntity() {
    return PrayerAlarm(
      time: time,
      prayer: PrayerInApp.values.firstWhere(
        (element) => element.name == prayer,
        orElse: () => PrayerInApp.imsak,
      ),
      alarmType: alarmType,
      reminderTime: reminderTime,
      reminderEnabled: reminderEnabled,
    );
  }
}
