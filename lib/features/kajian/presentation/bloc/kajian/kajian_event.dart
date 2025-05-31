part of 'kajian_bloc.dart';

@freezed
abstract class KajianEvent with _$KajianEvent {
  const factory KajianEvent.fetchKajian({
    required int pageNumber,
    required Locale locale,
    String? search,
  }) = _FetchKajian;

  const factory KajianEvent.fetchNearbyKajian({
    required Locale locale,
  }) = _FetchNearbyKajian;

  const factory KajianEvent.toggleNearby() = _ToggleNearby;

  const factory KajianEvent.fetchKajianThemes() = _FetchKajianThemes;

  const factory KajianEvent.fetchProvinces() = _FetchProvinces;

  const factory KajianEvent.fetchCities() = _FetchCities;

  const factory KajianEvent.fetchMosques() = _FetchMosques;

  const factory KajianEvent.fetchUstadz() = _FetchUstadz;

  const factory KajianEvent.onChangeSearch(String search) = _OnChangeSearch;

  const factory KajianEvent.onChangeFilterProvince(
      Pair<String, String>? filterProvince) = _OnChangeFilterProvince;

  const factory KajianEvent.onChangeFilterCity(
      Pair<String, String>? filterCity) = _OnChangeFilterCity;

  const factory KajianEvent.onChangeFilterMosque(
      Pair<String, String>? filterMosque) = _OnChangeFilterMosque;

  /// can multiple ustadz id
  const factory KajianEvent.onChangeFilterUstadz(
      Pair<String, String>? filterUstadz) = _OnChangeFilterUstadz;

  /// can multiple theme id
  const factory KajianEvent.onChangeFilterTheme(
      Pair<String, String>? filterTheme) = _OnChangeFilterTheme;

  const factory KajianEvent.onChangePrayerSchedule(
      Pair<String, String>? prayerSchedule) = _OnChangePrayerSchedule;

  /// can multiple day id
  const factory KajianEvent.onChangeDailySchedulesDayId(
      Pair<String, String>? dailySchedulesDayId) = _OnChangeDailySchedulesDayId;

  /// can multiple week id
  const factory KajianEvent.onChangeWeeklySchedulesWeekId(
          Pair<String, String>? weeklySchedulesWeekId) =
      _OnChangeWeeklySchedulesWeekId;

  const factory KajianEvent.onChangeFilterDate(DateTime? date) =
      _OnChangeFilterDate;

  const factory KajianEvent.resetFilter() = _ResetFilter;
}
