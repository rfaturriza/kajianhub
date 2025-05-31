part of 'prayer_schedule_bloc.dart';

@freezed
abstract class PrayerScheduleEvent with _$PrayerScheduleEvent {
  const factory PrayerScheduleEvent.fetchPrayerKajianSchedules({
    required Locale locale,
    required int pageNumber,
    String? search,
  }) = _FetchPrayerKajianSchedules;

  const factory PrayerScheduleEvent.toggleNearby() = _ToggleNearby;

  const factory PrayerScheduleEvent.fetchProvinces() = _FetchProvinces;

  const factory PrayerScheduleEvent.fetchCities() = _FetchCities;

  const factory PrayerScheduleEvent.fetchMosques() = _FetchMosques;

  const factory PrayerScheduleEvent.onChangeFilterProvince(
      Pair<String, String>? filterProvince) = _OnChangeFilterProvince;

  const factory PrayerScheduleEvent.onChangeFilterCity(
      Pair<String, String>? filterCity) = _OnChangeFilterCity;

  const factory PrayerScheduleEvent.onChangeFilterMosque(
      Pair<String, String>? filterMosque) = _OnChangeFilterMosque;

  const factory PrayerScheduleEvent.onChangeFilterKhatib(String? filterKhatib) =
      _OnChangeFilterKhatib;

  const factory PrayerScheduleEvent.onChangeFilterImam(String? filterImam) =
      _OnChangeFilterImam;

  const factory PrayerScheduleEvent.onChangeFilterPrayDate(DateTime? prayDate) =
      _OnChangeFilterPrayDate;

  const factory PrayerScheduleEvent.onChangeFilterSubtype(
      Pair<String, String>? filterSubtype) = _OnChangeFilterSubtype;

  const factory PrayerScheduleEvent.resetFilter() = _ResetFilter;
}
