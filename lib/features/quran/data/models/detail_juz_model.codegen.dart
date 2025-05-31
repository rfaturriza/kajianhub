import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quranku/features/quran/domain/entities/detail_juz.codegen.dart';

import 'verses_model.codegen.dart';

part 'detail_juz_model.codegen.freezed.dart';
part 'detail_juz_model.codegen.g.dart';

@freezed
abstract class DetailJuzResponseModel with _$DetailJuzResponseModel {
  const factory DetailJuzResponseModel({
    int? code,
    String? status,
    String? message,
    DataDetailJuzModel? data,
  }) = _DetailJuzResponseModel;

  factory DetailJuzResponseModel.fromJson(Map<String, dynamic> json) =>
      _$DetailJuzResponseModelFromJson(json);
}

@freezed
abstract class DataDetailJuzModel with _$DataDetailJuzModel {
  const factory DataDetailJuzModel({
    int? juz,
    int? juzStartSurahNumber,
    int? juzEndSurahNumber,
    String? juzStartInfo,
    String? juzEndInfo,
    int? totalVerses,
    List<VersesModel>? verses,
  }) = _DataDetailJuzModel;

  const DataDetailJuzModel._();

  factory DataDetailJuzModel.fromJson(Map<String, dynamic> json) =>
      _$DataDetailJuzModelFromJson(json);

  factory DataDetailJuzModel.fromEntity(DetailJuz entity) => DataDetailJuzModel(
        juz: entity.juz,
        juzStartSurahNumber: entity.juzStartSurahNumber,
        juzEndSurahNumber: entity.juzEndSurahNumber,
        juzStartInfo: entity.juzStartInfo,
        juzEndInfo: entity.juzEndInfo,
        totalVerses: entity.totalVerses,
        verses: entity.verses?.map((e) => e.toModel()).toList(),
      );

  DetailJuz toEntity() => DetailJuz(
        juz: juz,
        juzStartSurahNumber: juzStartSurahNumber,
        juzEndSurahNumber: juzEndSurahNumber,
        juzStartInfo: juzStartInfo,
        juzEndInfo: juzEndInfo,
        totalVerses: totalVerses,
        verses: verses?.map((e) => e.toEntity()).toList(),
      );
}
