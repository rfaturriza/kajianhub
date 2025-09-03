import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quranku/core/utils/extension/string_ext.dart';
import 'package:quranku/features/kajian/domain/entities/kajian_schedule.codegen.dart';

part 'kajian_themes_response_model.codegen.freezed.dart';
part 'kajian_themes_response_model.codegen.g.dart';

@freezed
abstract class KajianThemesResponseModel with _$KajianThemesResponseModel {
  const factory KajianThemesResponseModel({
    List<DataKajianThemeModel>? data,
  }) = _KajianThemesResponseModel;

  const KajianThemesResponseModel._();

  factory KajianThemesResponseModel.fromJson(Map<String, dynamic> json) =>
      _$KajianThemesResponseModelFromJson(json);

  List<KajianTheme> toEntities() {
    return data?.map((e) => e.toEntity()).toList() ?? [];
  }
}

@freezed
abstract class DataKajianThemeModel with _$DataKajianThemeModel {
  const factory DataKajianThemeModel({
    int? id,
    String? name,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _DataKajianThemeModel;

  const DataKajianThemeModel._();

  factory DataKajianThemeModel.fromJson(Map<String, dynamic> json) =>
      _$DataKajianThemeModelFromJson(json);

  KajianTheme toEntity() {
    return KajianTheme(
      id: id ?? 0,
      theme: name ?? emptyString,
      themeId: id?.toString() ?? emptyString,
    );
  }
}
