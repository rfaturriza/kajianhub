import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/surah_name.codegen.dart';
import 'language_model.codegen.dart';

part 'surah_name_model.codegen.freezed.dart';
part 'surah_name_model.codegen.g.dart';

@freezed
abstract class SurahNameModel with _$SurahNameModel {
  const factory SurahNameModel({
    String? short,
    String? long,
    LanguageModel? transliteration,
    LanguageModel? translation,
  }) = _SurahNameModel;

  const SurahNameModel._();

  factory SurahNameModel.fromJson(Map<String, dynamic> json) =>
      _$SurahNameModelFromJson(json);

  factory SurahNameModel.fromEntity(SurahName entity) => SurahNameModel(
        short: entity.short,
        long: entity.long,
        transliteration: entity.transliteration?.toModel(),
        translation: entity.translation?.toModel(),
      );

  SurahName toEntity() => SurahName(
        short: short,
        long: long,
        transliteration: transliteration?.toEntity(),
        translation: translation?.toEntity(),
      );
}
