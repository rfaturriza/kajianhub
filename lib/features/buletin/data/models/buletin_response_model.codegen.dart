import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quranku/features/buletin/data/models/buletin_model.codegen.dart';
import 'package:quranku/features/buletin/domain/entities/buletin.codegen.dart';

part 'buletin_response_model.codegen.freezed.dart';
part 'buletin_response_model.codegen.g.dart';

@freezed
abstract class BuletinResponseModel with _$BuletinResponseModel {
  const factory BuletinResponseModel({
    List<BuletinModel>? data,
    BuletinLinksModel? links,
    BuletinMetaModel? meta,
  }) = _BuletinResponseModel;

  const BuletinResponseModel._();

  factory BuletinResponseModel.fromJson(Map<String, dynamic> json) =>
      _$BuletinResponseModelFromJson(json);

  List<Buletin> toEntities() {
    return data?.map((e) => e.toEntity()).toList() ?? [];
  }
}

@freezed
abstract class BuletinLinksModel with _$BuletinLinksModel {
  const factory BuletinLinksModel({
    String? first,
    String? last,
    String? prev,
    String? next,
  }) = _BuletinLinksModel;

  factory BuletinLinksModel.fromJson(Map<String, dynamic> json) =>
      _$BuletinLinksModelFromJson(json);
}

@freezed
abstract class BuletinMetaModel with _$BuletinMetaModel {
  const factory BuletinMetaModel({
    @JsonKey(name: 'current_page') int? currentPage,
    int? from,
    @JsonKey(name: 'last_page') int? lastPage,
    String? path,
    @JsonKey(name: 'per_page') int? perPage,
    int? to,
    int? total,
  }) = _BuletinMetaModel;

  factory BuletinMetaModel.fromJson(Map<String, dynamic> json) =>
      _$BuletinMetaModelFromJson(json);
}
