import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/prayer_kajian_schedules.codegen.dart';
import 'kajian_schedules_response_model.codegen.dart';
import 'study_locations_response_model.codegen.dart';

part 'prayer_kajian_schedules_response_model.codegen.freezed.dart';
part 'prayer_kajian_schedules_response_model.codegen.g.dart';

@freezed
abstract class PrayerKajianSchedulesByMosqueResponseModel
    with _$PrayerKajianSchedulesByMosqueResponseModel {
  const factory PrayerKajianSchedulesByMosqueResponseModel({
    String? prayDate,
    DataPrayerKajianScheduleModel? data,
  }) = _PrayerKajianSchedulesByMosqueResponseModel;

  factory PrayerKajianSchedulesByMosqueResponseModel.fromJson(
          Map<String, dynamic> json) =>
      _$PrayerKajianSchedulesByMosqueResponseModelFromJson(json);
}

@freezed
abstract class PrayerKajianSchedulesResponseModel
    with _$PrayerKajianSchedulesResponseModel {
  const factory PrayerKajianSchedulesResponseModel({
    List<PrayerKajianScheduleModel>? data,
    LinksKajianScheduleModel? links,
    MetaKajianScheduleModel? meta,
  }) = _PrayerKajianSchedulesResponseModel;

  const PrayerKajianSchedulesResponseModel._();

  factory PrayerKajianSchedulesResponseModel.fromJson(
          Map<String, dynamic> json) =>
      _$PrayerKajianSchedulesResponseModelFromJson(json);

  PrayerkajianSchedules toEntity() {
    return PrayerkajianSchedules(
      data: data?.map((e) => e.toEntity()).toList() ?? [],
      links: links?.toEntity() ?? LinksKajianScheduleModel.empty().toEntity(),
      meta: meta?.toEntity() ?? MetaKajianScheduleModel.empty().toEntity(),
    );
  }
}

@freezed
abstract class DataPrayerKajianScheduleModel
    with _$DataPrayerKajianScheduleModel {
  const factory DataPrayerKajianScheduleModel({
    DataStudyLocationModel? studyLocation,
    List<PrayerKajianScheduleModel>? schedules,
  }) = _DataPrayerKajianScheduleModel;

  factory DataPrayerKajianScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$DataPrayerKajianScheduleModelFromJson(json);
}

@freezed
abstract class PrayerKajianScheduleModel with _$PrayerKajianScheduleModel {
  const factory PrayerKajianScheduleModel({
    int? id,
    @JsonKey(name: 'pray_date') String? prayDate,
    @JsonKey(name: 'location_id') String? locationId,
    @JsonKey(name: 'type_id') String? typeId,
    @JsonKey(name: 'type_label') String? typeLabel,
    @JsonKey(name: 'subtype_id') String? subtypeId,
    @JsonKey(name: 'subtype_label') String? subtypeLabel,
    String? bilal,
    String? khatib,
    String? imam,
    String? link,
    DataStudyLocationModel? studyLocation,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    @JsonKey(name: 'deleted_at') String? deletedAt,
    @JsonKey(name: 'created_by') String? createdBy,
    @JsonKey(name: 'updated_by') String? updatedBy,
    @JsonKey(name: 'deleted_by') String? deletedBy,
  }) = _PrayerKajianScheduleModel;

  const PrayerKajianScheduleModel._();

  factory PrayerKajianScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$PrayerKajianScheduleModelFromJson(json);

  PrayerKajianSchedule toEntity() {
    return PrayerKajianSchedule(
      id: id,
      prayDate: prayDate,
      locationId: locationId,
      typeId: typeId,
      typeLabel: typeLabel,
      subtypeId: subtypeId,
      subtypeLabel: subtypeLabel,
      bilal: bilal,
      khatib: khatib,
      imam: imam,
      link: link,
      studyLocation: studyLocation?.toEntity(),
    );
  }
}
