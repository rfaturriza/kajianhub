import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quranku/core/utils/pair.dart';

part 'filter_kajian_schedule.codegen.freezed.dart';

@freezed
abstract class FilterKajianSchedule with _$FilterKajianSchedule {
  const factory FilterKajianSchedule({
    Pair<String, String>? studyLocationProvinceId,
    Pair<String, String>? studyLocationCityId,
    Pair<String, String>? locationId,

    /// can multiple day id
    Pair<String, String>? dailySchedulesDayId,

    /// can multiple week id
    Pair<String, String>? weeklySchedulesWeekId,
    Pair<String, String>? prayerSchedule,

    /// can multiple theme id
    Pair<String, String>? themesThemeId,

    /// can multiple ustadz id
    Pair<String, String>? ustadzUstadzId,
    DateTime? date,
    @Default(false) bool isNearby,
  }) = _FilterKajianSchedule;

  const FilterKajianSchedule._();

  bool get isEmpty {
    return this == const FilterKajianSchedule();
  }

  bool get isNotEmpty {
    return this != const FilterKajianSchedule();
  }
}
