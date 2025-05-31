import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/kajian_schedule.codegen.dart';
import 'kajian_schedules_response_model.codegen.dart';

part 'cities_response_model.codegen.freezed.dart';
part 'cities_response_model.codegen.g.dart';

@freezed
abstract class CitiesResponseModel with _$CitiesResponseModel {
  const factory CitiesResponseModel({
    List<DataCitiesModel>? data,
  }) = _CitiesResponseModel;

  factory CitiesResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CitiesResponseModelFromJson(json);
}

@freezed
abstract class DataCitiesModel with _$DataCitiesModel {
  const factory DataCitiesModel({
    int? id,
    String? name,
    @JsonKey(name: 'province_id') String? provinceId,
    ProvinceModel? province,
  }) = _DataCitiesModel;

  const DataCitiesModel._();

  factory DataCitiesModel.fromJson(Map<String, dynamic> json) =>
      _$DataCitiesModelFromJson(json);

  City toEntity() {
    return City(
      id: id ?? 0,
      name: name ?? '',
      provinceId: provinceId ?? '',
    );
  }
}
