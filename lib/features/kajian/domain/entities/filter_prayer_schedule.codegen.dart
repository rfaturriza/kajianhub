import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quranku/core/utils/pair.dart';

part 'filter_prayer_schedule.codegen.freezed.dart';

@freezed
abstract class FilterPrayerSchedule with _$FilterPrayerSchedule {
  const factory FilterPrayerSchedule({
    Pair<String, String>? studyLocationProvinceId,
    Pair<String, String>? studyLocationCityId,
    Pair<String, String>? locationId,
    Pair<String, String>? prayerSchedule,
    DateTime? prayDate,
    String? imam,
    String? khatib,
    @Default(false) bool isNearby,
  }) = _FilterPrayerSchedule;

  const FilterPrayerSchedule._();

  int get totalActive {
    int count = 0;
    if (studyLocationProvinceId != null) count++;
    if (studyLocationCityId != null) count++;
    if (locationId != null) count++;
    if (imam != null) count++;
    if (khatib != null) count++;
    if (isNearby) count++;
    return count;
  }

  bool isEmpty() {
    return this == const FilterPrayerSchedule();
  }

  bool isNotEmpty() {
    return this != const FilterPrayerSchedule();
  }
}
