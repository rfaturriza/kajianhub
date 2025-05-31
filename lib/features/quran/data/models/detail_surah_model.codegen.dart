import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quranku/features/quran/data/models/language_model.codegen.dart';

import '../../domain/entities/detail_surah.codegen.dart';
import 'surah_name_model.codegen.dart';
import 'verses_model.codegen.dart';

part 'detail_surah_model.codegen.freezed.dart';

part 'detail_surah_model.codegen.g.dart';

@freezed
abstract class DetailSurahResponseModel with _$DetailSurahResponseModel {
  const factory DetailSurahResponseModel({
    int? code,
    String? status,
    String? message,
    DataDetailSurahModel? data,
  }) = _DetailSurahResponseModel;

  factory DetailSurahResponseModel.fromJson(Map<String, dynamic> json) =>
      _$DetailSurahResponseModelFromJson(json);
}

@freezed
abstract class DataDetailSurahModel with _$DataDetailSurahModel {
  const factory DataDetailSurahModel({
    int? number,
    int? sequence,
    int? numberOfVerses,
    SurahNameModel? name,
    LanguageModel? revelation,
    LanguageModel? tafsir,
    PreBismillahModel? preBismillah,
    List<VersesModel>? verses,
  }) = _DataDetailSurahModel;

  const DataDetailSurahModel._();

  factory DataDetailSurahModel.fromJson(Map<String, dynamic> json) =>
      _$DataDetailSurahModelFromJson(json);

  factory DataDetailSurahModel.fromEntity(DetailSurah entity) =>
      DataDetailSurahModel(
        number: entity.number,
        sequence: entity.sequence,
        numberOfVerses: entity.numberOfVerses,
        name: entity.name?.toModel(),
        revelation: entity.revelation?.toModel(),
        tafsir: entity.tafsir?.toModel(),
        preBismillah: entity.preBismillah?.toModel(),
        verses: entity.verses?.map((e) => e.toModel()).toList(),
      );

  DetailSurah toEntity() => DetailSurah(
        number: number,
        sequence: sequence,
        numberOfVerses: numberOfVerses,
        name: name?.toEntity(),
        revelation: revelation?.toEntity(),
        tafsir: tafsir?.toEntity(),
        preBismillah: preBismillah?.toEntity(),
        verses: verses?.map((e) => e.toEntity()).toList(),
      );
}

@freezed
abstract class PreBismillahModel with _$PreBismillahModel {
  const factory PreBismillahModel({
    VersesTextModel? text,
  }) = _PreBismillahModel;

  const PreBismillahModel._();

  factory PreBismillahModel.fromJson(Map<String, dynamic> json) =>
      _$PreBismillahModelFromJson(json);

  factory PreBismillahModel.fromEntity(PreBismillah entity) =>
      PreBismillahModel(
        text: entity.text?.toModel(),
      );

  PreBismillah toEntity() => PreBismillah(
        text: text?.toEntity(),
      );
}
