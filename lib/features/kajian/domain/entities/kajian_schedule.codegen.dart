import 'package:freezed_annotation/freezed_annotation.dart';

import 'study_location_entity.dart';

part 'kajian_schedule.codegen.freezed.dart';

@freezed
abstract class KajianSchedules with _$KajianSchedules {
  const factory KajianSchedules({
    required List<DataKajianSchedule> data,
    required LinksKajianSchedule links,
    required MetaKajianSchedule meta,
  }) = _KajianSchedules;
}

@freezed
abstract class DataKajianSchedule with _$DataKajianSchedule {
  const factory DataKajianSchedule({
    required int id,
    required String title,
    required String type,
    required String typeLabel,
    required String book,
    required String timeStart,
    required String timeEnd,
    required String prayerSchedule,
    required String locationId,
    required StudyLocationEntity studyLocation,
    required List<Ustadz> ustadz,
    required List<KajianTheme> themes,
    required List<DailySchedule> dailySchedules,
    required List<HistoryKajian> histories,
    required List<dynamic> customSchedules,
    String? distanceInKm,
  }) = _DataKajianSchedule;

  const DataKajianSchedule._();

  static DataKajianSchedule empty() {
    return DataKajianSchedule(
      id: 0,
      title: '',
      type: '',
      typeLabel: '',
      book: '',
      timeStart: '',
      timeEnd: '',
      prayerSchedule: '',
      locationId: '',
      studyLocation: StudyLocationEntity(),
      ustadz: [],
      themes: [],
      dailySchedules: [],
      histories: [],
      customSchedules: [],
    );
  }
}

@freezed
abstract class HistoryKajian with _$HistoryKajian {
  const factory HistoryKajian({
    required int id,
    required String kajianId,
    required String url,
    required String title,
    required String publishedAt,
  }) = _HistoryKajian;
}

@freezed
abstract class Province with _$Province {
  const factory Province({
    required int id,
    required String name,
  }) = _Province;
}

@freezed
abstract class City with _$City {
  const factory City({
    required int id,
    required String name,
    required String provinceId,
  }) = _City;
}

@freezed
abstract class Ustadz with _$Ustadz {
  const factory Ustadz({
    required int id,
    required String ustadzId,
    required String name,
    required String email,
    required String placeOfBirth,
    required String dateOfBirth,
    required String contactPerson,
  }) = _Ustadz;
}

@freezed
abstract class KajianTheme with _$KajianTheme {
  const factory KajianTheme({
    required int id,
    required String themeId,
    required String theme,
  }) = _KajianTheme;
}

@freezed
abstract class DailySchedule with _$DailySchedule {
  const factory DailySchedule({
    required int id,
    required String dayId,
    required String dayLabel,
  }) = _DailySchedule;
}

@freezed
abstract class LinksKajianSchedule with _$LinksKajianSchedule {
  const factory LinksKajianSchedule({
    String? first,
    String? last,
    String? prev,
    String? next,
  }) = _LinksKajianSchedule;
}

@freezed
abstract class MetaKajianSchedule with _$MetaKajianSchedule {
  const factory MetaKajianSchedule({
    int? currentPage,
    int? from,
    int? lastPage,
    List<LinksMeta>? links,
    String? path,
    int? perPage,
    int? to,
    int? total,
  }) = _MetaKajianSchedule;
}

@freezed
abstract class LinksMeta with _$LinksMeta {
  const factory LinksMeta({
    String? url,
    String? label,
    bool? active,
  }) = _LinksMeta;
}
