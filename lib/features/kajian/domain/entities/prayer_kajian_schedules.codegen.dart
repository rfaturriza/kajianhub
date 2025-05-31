import 'package:freezed_annotation/freezed_annotation.dart';

import 'kajian_schedule.codegen.dart';

part 'prayer_kajian_schedules.codegen.freezed.dart';

@freezed
abstract class PrayerkajianSchedules with _$PrayerkajianSchedules {
  const factory PrayerkajianSchedules({
    required List<PrayerKajianSchedule> data,
    required LinksKajianSchedule links,
    required MetaKajianSchedule meta,
  }) = _PrayerkajianSchedules;
}

@freezed
abstract class PrayerKajianSchedule with _$PrayerKajianSchedule {
  const factory PrayerKajianSchedule({
    int? id,
    String? prayDate,
    String? locationId,
    String? typeId,
    String? typeLabel,
    String? subtypeId,
    String? subtypeLabel,
    String? bilal,
    String? khatib,
    String? imam,
    String? link,
    StudyLocation? studyLocation,
  }) = _PrayerKajianSchedule;
}
