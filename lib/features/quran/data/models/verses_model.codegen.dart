import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quranku/features/quran/data/models/language_model.codegen.dart';

import '../../domain/entities/verses.codegen.dart';

part 'verses_model.codegen.freezed.dart';
part 'verses_model.codegen.g.dart';

@freezed
abstract class VersesModel with _$VersesModel {
  const factory VersesModel({
    VersesNumberModel? number,
    VersesMetaModel? meta,
    VersesTextModel? text,
    LanguageModel? translation,
    AudioModel? audio,
    VersesTafsirModel? tafsir,
  }) = _VersesModel;

  const VersesModel._();

  factory VersesModel.fromJson(Map<String, dynamic> json) =>
      _$VersesModelFromJson(json);

  factory VersesModel.fromEntity(Verses entity) => VersesModel(
        number: entity.number?.toModel(),
        meta: entity.meta?.toModel(),
        text: entity.text?.toModel(),
        translation: entity.translation?.toModel(),
        audio: entity.audio?.toModel(),
        tafsir: entity.tafsir?.toModel(),
      );

  Verses toEntity() => Verses(
        number: number?.toEntity(),
        meta: meta?.toEntity(),
        text: text?.toEntity(),
        translation: translation?.toEntity(),
        audio: audio?.toEntity(),
        tafsir: tafsir?.toEntity(),
      );
}

@freezed
abstract class VersesNumberModel with _$VersesNumberModel {
  const factory VersesNumberModel({
    int? inQuran,
    int? inSurah,
  }) = _VersesNumberModel;

  const VersesNumberModel._();
  factory VersesNumberModel.fromJson(Map<String, dynamic> json) =>
      _$VersesNumberModelFromJson(json);

  factory VersesNumberModel.fromEntity(VersesNumber entity) =>
      VersesNumberModel(
        inQuran: entity.inQuran,
        inSurah: entity.inSurah,
      );

  VersesNumber toEntity() => VersesNumber(
        inQuran: inQuran,
        inSurah: inSurah,
      );
}

@freezed
abstract class VersesMetaModel with _$VersesMetaModel {
  const factory VersesMetaModel({
    int? juz,
    int? page,
    int? manzil,
    int? ruku,
    int? hizbQuarter,
    VersesSajdaModel? sajda,
  }) = _VersesMetaModel;

  const VersesMetaModel._();
  factory VersesMetaModel.fromJson(Map<String, dynamic> json) =>
      _$VersesMetaModelFromJson(json);

  factory VersesMetaModel.fromEntity(VersesMeta entity) => VersesMetaModel(
        juz: entity.juz,
        page: entity.page,
        manzil: entity.manzil,
        ruku: entity.ruku,
        hizbQuarter: entity.hizbQuarter,
        sajda: entity.sajda?.toModel(),
      );

  VersesMeta toEntity() => VersesMeta(
        juz: juz,
        page: page,
        manzil: manzil,
        ruku: ruku,
        hizbQuarter: hizbQuarter,
        sajda: sajda?.toEntity(),
      );
}

@freezed
abstract class VersesSajdaModel with _$VersesSajdaModel {
  const factory VersesSajdaModel({
    bool? recommended,
    bool? obligatory,
  }) = _SajdaModel;

  const VersesSajdaModel._();
  factory VersesSajdaModel.fromJson(Map<String, dynamic> json) =>
      _$VersesSajdaModelFromJson(json);

  factory VersesSajdaModel.fromEntity(VersesSajda entity) => VersesSajdaModel(
        recommended: entity.recommended,
        obligatory: entity.obligatory,
      );

  VersesSajda toEntity() => VersesSajda(
        recommended: recommended,
        obligatory: obligatory,
      );
}

@freezed
abstract class VersesTextModel with _$VersesTextModel {
  const factory VersesTextModel({
    String? arab,
    LanguageModel? transliteration,
  }) = _VersesTextModel;

  const VersesTextModel._();
  factory VersesTextModel.fromJson(Map<String, dynamic> json) =>
      _$VersesTextModelFromJson(json);

  factory VersesTextModel.fromEntity(VersesText entity) => VersesTextModel(
        arab: entity.arab,
        transliteration: entity.transliteration?.toModel(),
      );

  VersesText toEntity() => VersesText(
        arab: arab,
        transliteration: transliteration?.toEntity(),
      );
}

@freezed
abstract class AudioModel with _$AudioModel {
  const factory AudioModel({
    String? primary,
    List<String>? secondary,
  }) = _AudioModel;

  const AudioModel._();
  factory AudioModel.fromJson(Map<String, dynamic> json) =>
      _$AudioModelFromJson(json);

  factory AudioModel.fromEntity(Audio entity) => AudioModel(
        primary: entity.primary,
        secondary: entity.secondary,
      );

  Audio toEntity() => Audio(
        primary: primary,
        secondary: secondary,
      );
}

@freezed
abstract class VersesTafsirModel with _$VersesTafsirModel {
  const factory VersesTafsirModel({
    TypeVersesTafsirModel? id,
  }) = _VersesTafsirModel;

  const VersesTafsirModel._();
  factory VersesTafsirModel.fromJson(Map<String, dynamic> json) =>
      _$VersesTafsirModelFromJson(json);

  factory VersesTafsirModel.fromEntity(VersesTafsir entity) =>
      VersesTafsirModel(
        id: entity.id?.toModel(),
      );

  VersesTafsir toEntity() => VersesTafsir(
        id: id?.toEntity(),
      );
}

@freezed
abstract class TypeVersesTafsirModel with _$TypeVersesTafsirModel {
  const factory TypeVersesTafsirModel({
    String? short,
    String? long,
  }) = _TypeVersesTafsirModel;

  const TypeVersesTafsirModel._();
  factory TypeVersesTafsirModel.fromJson(Map<String, dynamic> json) =>
      _$TypeVersesTafsirModelFromJson(json);

  factory TypeVersesTafsirModel.fromEntity(TypeVersesTafsir entity) =>
      TypeVersesTafsirModel(
        short: entity.short,
        long: entity.long,
      );

  TypeVersesTafsir toEntity() => TypeVersesTafsir(
        short: short,
        long: long,
      );
}
