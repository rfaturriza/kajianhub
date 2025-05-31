import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quranku/core/utils/extension/string_ext.dart';
import 'package:quranku/features/kajian/domain/entities/kajian_schedule.codegen.dart';

import 'kajian_schedules_response_model.codegen.dart';

part 'provinces_response_model.codegen.freezed.dart';
part 'provinces_response_model.codegen.g.dart';

@freezed
abstract class ProvincesResponseModel with _$ProvincesResponseModel {
  const factory ProvincesResponseModel({
    List<DataProvincesModel>? data,
  }) = _ProvincesResponseModel;

  factory ProvincesResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ProvincesResponseModelFromJson(json);
}

@freezed
abstract class DataProvincesModel with _$DataProvincesModel {
  const factory DataProvincesModel({
    int? id,
    String? name,
    List<CityModel>? cities,
  }) = _DataProvincesModel;

  const DataProvincesModel._();

  factory DataProvincesModel.fromJson(Map<String, dynamic> json) =>
      _$DataProvincesModelFromJson(json);

  Province toEntity() {
    return Province(
      id: id ?? 0,
      name: name?.toLowerCase().capitalizeEveryWord() ?? '',
    );
  }
}
