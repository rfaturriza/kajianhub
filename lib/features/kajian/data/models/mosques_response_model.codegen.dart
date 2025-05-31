import 'package:freezed_annotation/freezed_annotation.dart';

import 'kajian_schedules_response_model.codegen.dart';

part 'mosques_response_model.codegen.freezed.dart';
part 'mosques_response_model.codegen.g.dart';

@freezed
abstract class MosquesResponseModel with _$MosquesResponseModel {
  const factory MosquesResponseModel({
    List<DataMosqueModel>? data,
  }) = _MosquesResponseModel;

  factory MosquesResponseModel.fromJson(Map<String, dynamic> json) =>
      _$MosquesResponseModelFromJson(json);
}

@freezed
abstract class DataMosqueModel with _$DataMosqueModel {
  const factory DataMosqueModel({
    int? id,
    String? name,
    String? village,
    String? address,
    @JsonKey(name: 'province_id') String? provinceId,
    @JsonKey(name: 'city_id') String? cityId,
    @JsonKey(name: 'google_maps') String? googleMaps,
    String? longitude,
    String? latitude,
    @JsonKey(name: 'contact_person') String? contactPerson,
    String? picture,
    @JsonKey(name: 'picture_url') String? pictureUrl,
    ProvinceModel? province,
    CityModel? city,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _DataMosqueModel;

  factory DataMosqueModel.fromJson(Map<String, dynamic> json) =>
      _$DataMosqueModelFromJson(json);
}
