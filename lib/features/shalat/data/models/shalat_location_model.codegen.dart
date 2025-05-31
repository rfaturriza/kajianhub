import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/shalat_location.codegen.dart';

part 'shalat_location_model.codegen.freezed.dart';

part 'shalat_location_model.codegen.g.dart';

@freezed
abstract class ShalatLocationResponseModel with _$ShalatLocationResponseModel {
  const factory ShalatLocationResponseModel({
    bool? status,
    List<ShalatLocationModel>? data,
  }) = _ShalatLocationResponseModel;

  const ShalatLocationResponseModel._();
  factory ShalatLocationResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ShalatLocationResponseModelFromJson(json);

  List<ShalatLocation> toEntity() =>
      data?.map((e) => e.toEntity()).toList() ?? [];
}

@freezed
abstract class ShalatLocationModel with _$ShalatLocationModel {
  const factory ShalatLocationModel({
    String? id,
    @JsonKey(name: 'lokasi') String? location,
  }) = _ShalatLocationModel;

  const ShalatLocationModel._();
  factory ShalatLocationModel.fromJson(Map<String, dynamic> json) =>
      _$ShalatLocationModelFromJson(json);

  factory ShalatLocationModel.fromEntity(ShalatLocation entity) =>
      ShalatLocationModel(
        id: entity.id,
        location: entity.location,
      );

  ShalatLocation toEntity() => ShalatLocation(
        id: id,
        location: location,
      );
}
