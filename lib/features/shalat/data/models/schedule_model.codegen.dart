import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/schedule.codegen.dart';

part 'schedule_model.codegen.freezed.dart';

part 'schedule_model.codegen.g.dart';

@freezed
abstract class ScheduleResponseByDayModel with _$ScheduleResponseByDayModel {
  const factory ScheduleResponseByDayModel({
    bool? status,
    @JsonKey(name: 'data') DataScheduleByDayModel? dataByDay,
  }) = _ScheduleResponseByDayModel;

  const ScheduleResponseByDayModel._();
  factory ScheduleResponseByDayModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduleResponseByDayModelFromJson(json);
}

@freezed
abstract class ScheduleResponseByMonthModel
    with _$ScheduleResponseByMonthModel {
  const factory ScheduleResponseByMonthModel({
    bool? status,
    @JsonKey(name: 'data') DataScheduleByMonthModel? dataByMonth,
  }) = _ScheduleResponseByMonthModel;
  const ScheduleResponseByMonthModel._();

  factory ScheduleResponseByMonthModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduleResponseByMonthModelFromJson(json);
}

@freezed
abstract class DataScheduleByDayModel with _$DataScheduleByDayModel {
  const factory DataScheduleByDayModel({
    String? id,
    @JsonKey(name: 'lokasi') String? location,
    @JsonKey(name: 'daerah') String? area,
    @JsonKey(name: 'koordinat') CoordinateModel? coordinate,
    @JsonKey(name: 'jadwal') ScheduleModel? schedule,
  }) = _DataScheduleByDayModel;

  const DataScheduleByDayModel._();

  factory DataScheduleByDayModel.fromJson(Map<String, dynamic> json) =>
      _$DataScheduleByDayModelFromJson(json);

  factory DataScheduleByDayModel.fromEntity(ScheduleByDay entity) =>
      DataScheduleByDayModel(
        id: entity.id,
        location: entity.location,
        area: entity.area,
        coordinate: entity.coordinate?.toModel(),
        schedule: entity.schedule?.toModel(),
      );

  ScheduleByDay toEntity() => ScheduleByDay(
        id: id,
        location: location,
        area: area,
        coordinate: coordinate?.toEntity(),
        schedule: schedule?.toEntity(),
      );
}

@freezed
abstract class DataScheduleByMonthModel with _$DataScheduleByMonthModel {
  const factory DataScheduleByMonthModel({
    String? id,
    @JsonKey(name: 'lokasi') String? location,
    @JsonKey(name: 'daerah') String? area,
    @JsonKey(name: 'koordinat') CoordinateModel? coordinate,
    @JsonKey(name: 'jadwal') List<ScheduleModel>? schedule,
  }) = _DataScheduleByMonthModel;

  const DataScheduleByMonthModel._();

  factory DataScheduleByMonthModel.fromJson(Map<String, dynamic> json) =>
      _$DataScheduleByMonthModelFromJson(json);

  factory DataScheduleByMonthModel.fromEntity(ScheduleByMonth entity) =>
      DataScheduleByMonthModel(
        id: entity.id,
        location: entity.location,
        area: entity.area,
        coordinate: entity.coordinate?.toModel(),
        schedule: entity.schedule?.map((e) => e.toModel()).toList(),
      );

  ScheduleByMonth toEntity() => ScheduleByMonth(
        id: id,
        location: location,
        area: area,
        coordinate: coordinate?.toEntity(),
        schedule: schedule?.map((e) => e.toEntity()).toList(),
      );
}

@freezed
abstract class ScheduleModel with _$ScheduleModel {
  const factory ScheduleModel({
    @JsonKey(name: 'tanggal') String? date,
    String? imsak,
    String? subuh,
    String? syuruq,
    String? dhuha,
    String? dzuhur,
    String? ashar,
    String? maghrib,
    String? isya,
  }) = _ScheduleModel;

  const ScheduleModel._();

  factory ScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduleModelFromJson(json);

  factory ScheduleModel.fromEntity(Schedule entity) => ScheduleModel(
        date: entity.date,
        imsak: entity.imsak,
        subuh: entity.subuh,
        syuruq: entity.syuruq,
        dhuha: entity.dhuha,
        dzuhur: entity.dzuhur,
        ashar: entity.ashar,
        maghrib: entity.maghrib,
        isya: entity.isya,
      );

  Schedule toEntity() => Schedule(
        date: date,
        imsak: imsak,
        subuh: subuh,
        syuruq: syuruq,
        dhuha: dhuha,
        dzuhur: dzuhur,
        ashar: ashar,
        maghrib: maghrib,
        isya: isya,
      );
}

@freezed
abstract class CoordinateModel with _$CoordinateModel {
  const factory CoordinateModel({
    double? lat,
    double? lon,
    @JsonKey(name: 'lintang') String? latitude,
    @JsonKey(name: 'bujur') String? longitude,
  }) = _CoordinateModel;

  const CoordinateModel._();

  factory CoordinateModel.fromJson(Map<String, dynamic> json) =>
      _$CoordinateModelFromJson(json);

  factory CoordinateModel.fromEntity(Coordinate entity) => CoordinateModel(
        lat: entity.lat,
        lon: entity.lon,
        latitude: entity.latitude,
        longitude: entity.longitude,
      );

  Coordinate toEntity() => Coordinate(
        lat: lat,
        lon: lon,
        latitude: latitude,
        longitude: longitude,
      );
}
