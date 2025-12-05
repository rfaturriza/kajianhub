import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quranku/features/pray/data/models/prayer_model.codegen.dart';

part 'prayers_response_model.codegen.freezed.dart';
part 'prayers_response_model.codegen.g.dart';

@freezed
abstract class PrayersResponseModel with _$PrayersResponseModel {
  const factory PrayersResponseModel({
    List<PrayerModel>? data,
    PrayerPaginationLinksModel? links,
    PrayerPaginationMetaModel? meta,
  }) = _PrayersResponseModel;

  factory PrayersResponseModel.fromJson(Map<String, dynamic> json) =>
      _$PrayersResponseModelFromJson(json);
}

@freezed
abstract class PrayerPaginationLinksModel with _$PrayerPaginationLinksModel {
  const factory PrayerPaginationLinksModel({
    String? first,
    String? last,
    String? prev,
    String? next,
  }) = _PrayerPaginationLinksModel;

  factory PrayerPaginationLinksModel.fromJson(Map<String, dynamic> json) =>
      _$PrayerPaginationLinksModelFromJson(json);
}

@freezed
abstract class PrayerPaginationMetaModel with _$PrayerPaginationMetaModel {
  const factory PrayerPaginationMetaModel({
    @JsonKey(name: 'current_page') int? currentPage,
    int? from,
    @JsonKey(name: 'last_page') int? lastPage,
    String? path,
    @JsonKey(name: 'per_page') int? perPage,
    int? to,
    int? total,
  }) = _PrayerPaginationMetaModel;

  factory PrayerPaginationMetaModel.fromJson(Map<String, dynamic> json) =>
      _$PrayerPaginationMetaModelFromJson(json);
}
