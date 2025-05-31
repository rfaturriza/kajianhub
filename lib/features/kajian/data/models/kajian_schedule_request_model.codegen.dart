import 'package:freezed_annotation/freezed_annotation.dart';

part 'kajian_schedule_request_model.codegen.freezed.dart';
part 'kajian_schedule_request_model.codegen.g.dart';

@freezed
abstract class KajianScheduleRequestModel with _$KajianScheduleRequestModel {
  const factory KajianScheduleRequestModel({
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

    /// 0/1 -> 1 = menampilkan kajian berdasarkan jadwal harian dan mingguan
    @JsonKey(name: 'is_daily') int? isDaily,

    /// 0/1 -> 1 = menampilkan kajian berdasarkan lokasi anda (terdekat), wajib kirim longitude dan latitude
    @JsonKey(name: 'is_nearest') int? isNearest,
    double? latitude,
    double? longitude,

    /// 0/1 1 = menampilkan kajian yg tidak rutin, kirim date (defaultnya hari ini)
    @JsonKey(name: 'is_by_date') int? isByDate,
    String? date,

    /// filter,{relation}.{field},{operator},{value}
    @JsonKey(name: 'options[]') List<String>? options,
  }) = _KajianScheduleRequestModel;

  const KajianScheduleRequestModel._();

  factory KajianScheduleRequestModel.fromJson(Map<String, dynamic> json) =>
      _$KajianScheduleRequestModelFromJson(json);

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
