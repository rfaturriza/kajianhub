import 'package:freezed_annotation/freezed_annotation.dart';

part 'prayer_kajian_schedule_request_model.codegen.freezed.dart';
part 'prayer_kajian_schedule_request_model.codegen.g.dart';

@freezed
abstract class PrayerKajianScheduleByMosqueRequestModel
    with _$PrayerKajianScheduleByMosqueRequestModel {
  const factory PrayerKajianScheduleByMosqueRequestModel({
    @JsonKey(name: 'pray_date') String? prayDate,

    /// 0/1 -> 1 = menampilkan lokasi masjid terdekat, wajib kirim lotitude & longitude
    int? isNearest,
    double? latitude,
    double? longitude,

    /// filter,{relation}.{field},{operator},{value}
    List<String>? options,
  }) = _PrayerKajianScheduleByMosqueRequestModel;

  factory PrayerKajianScheduleByMosqueRequestModel.fromJson(
          Map<String, dynamic> json) =>
      _$PrayerKajianScheduleByMosqueRequestModelFromJson(json);
}

@freezed
abstract class PrayerKajianScheduleRequestModel
    with _$PrayerKajianScheduleRequestModel {
  const factory PrayerKajianScheduleRequestModel({
    /// type:pagination/collection
    required String type,

    /// q: search by judul kajian/nama masjid/nama ustad
    @JsonKey(name: 'q') String? query,
    required int page,
    required int limit,
    @JsonKey(name: 'order_by') required String orderBy,
    @JsonKey(name: 'sort_by') required String sortBy,

    /// relations: ustadz,studyLocation.province,studyLocation.city,dailySchedules,customSchedules,themes
    /// untuk menampilkan resource relasi
    required String relations,

    /// 0/1 -> 1 = menampilkan kajian berdasarkan lokasi anda (terdekat), wajib kirim longitude dan latitude
    @JsonKey(name: 'is_nearest') int? isNearest,
    double? latitude,
    double? longitude,
    @JsonKey(name: 'pray_date') String? prayDate,

    /// filter,{relation}.{field},{operator},{value}
    @JsonKey(name: 'options[]') List<String>? options,
  }) = _PrayerKajianScheduleRequestModel;

  const PrayerKajianScheduleRequestModel._();

  factory PrayerKajianScheduleRequestModel.fromJson(
          Map<String, dynamic> json) =>
      _$PrayerKajianScheduleRequestModelFromJson(json);

  Map<String, Object> toAnalytic() {
    final json = toJson();
    json.update(
      'options[]',
      (v) => (v as List<String>).join(','),
      ifAbsent: () => null,
    );
    json['options'] = json['options[]'];
    json.remove('options[]');
    json.removeWhere((k, v) => v == null);
    return json.cast<String, Object>();
  }
}
