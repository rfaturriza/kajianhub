import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quranku/features/quran/data/models/language_model.codegen.dart';

import '../../domain/entities/surah.codegen.dart';
import 'surah_name_model.codegen.dart';

part 'surah_model.codegen.freezed.dart';

part 'surah_model.codegen.g.dart';

@freezed
abstract class SurahResponseModel with _$SurahResponseModel {
  const factory SurahResponseModel({
    int? code,
    String? status,
    String? message,
    List<DataSurahModel>? data,
  }) = _SurahResponseModel;

  factory SurahResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SurahResponseModelFromJson(json);
}

@freezed
abstract class DataSurahModel with _$DataSurahModel {
  const factory DataSurahModel({
    int? number,
    int? sequence,
    int? numberOfVerses,
    SurahNameModel? name,
    LanguageModel? revelation,
    LanguageModel? tafsir,
  }) = _DataSurahModel;

  const DataSurahModel._();

  factory DataSurahModel.fromJson(Map<String, dynamic> json) =>
      _$DataSurahModelFromJson(json);

  factory DataSurahModel.fromEntity(Surah entity) => DataSurahModel(
        number: entity.number,
        sequence: entity.sequence,
        numberOfVerses: entity.numberOfVerses,
        name: entity.name?.toModel(),
        revelation: entity.revelation?.toModel(),
        tafsir: entity.tafsir?.toModel(),
      );

  Surah toEntity() => Surah(
        number: number,
        sequence: sequence,
        numberOfVerses: numberOfVerses,
        name: name?.toEntity(),
        revelation: revelation?.toEntity(),
        tafsir: tafsir?.toEntity(),
      );
}
