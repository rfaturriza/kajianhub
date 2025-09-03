import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quranku/features/quran/domain/entities/language.codegen.dart';

import '../../data/models/verses_model.codegen.dart';

part 'verses.codegen.freezed.dart';

@freezed
abstract class Verses with _$Verses {
  const factory Verses({
    bool? isBookmarked,
    VersesNumber? number,
    VersesMeta? meta,
    VersesText? text,
    Language? translation,
    Audio? audio,
    VersesTafsir? tafsir,
  }) = _Verses;

  const Verses._();

  VersesModel toModel() => VersesModel(
        number: number?.toModel(),
        meta: meta?.toModel(),
        text: text?.toModel(),
        translation: translation?.toModel(),
        audio: audio?.toModel(),
        tafsir: tafsir?.toModel(),
      );
}

@freezed
abstract class VersesNumber with _$VersesNumber {
  const factory VersesNumber({
    int? inQuran,
    int? inSurah,
  }) = _VersesNumber;

  const VersesNumber._();

  VersesNumberModel toModel() => VersesNumberModel(
        inQuran: inQuran,
        inSurah: inSurah,
      );
}

@freezed
abstract class VersesMeta with _$VersesMeta {
  const factory VersesMeta({
    int? juz,
    int? page,
    int? manzil,
    int? ruku,
    int? hizbQuarter,
    VersesSajda? sajda,
  }) = _VersesMeta;

  const VersesMeta._();

  VersesMetaModel toModel() => VersesMetaModel(
        juz: juz,
        page: page,
        manzil: manzil,
        ruku: ruku,
        hizbQuarter: hizbQuarter,
        sajda: sajda?.toModel(),
      );
}

@freezed
abstract class VersesSajda with _$VersesSajda {
  const factory VersesSajda({
    bool? recommended,
    bool? obligatory,
  }) = _VersesSajda;

  const VersesSajda._();

  VersesSajdaModel toModel() => VersesSajdaModel(
        recommended: recommended,
        obligatory: obligatory,
      );
}

@freezed
abstract class VersesText with _$VersesText {
  const factory VersesText({
    String? arab,
    Language? transliteration,
  }) = _VersesText;

  const VersesText._();

  VersesTextModel toModel() => VersesTextModel(
        arab: arab,
        transliteration: transliteration?.toModel(),
      );
}

@freezed
abstract class Audio with _$Audio {
  const factory Audio({
    String? primary,
    List<String>? secondary,
  }) = _Audio;

  const Audio._();

  AudioModel toModel() => AudioModel(
        primary: primary,
        secondary: secondary?.map((e) => e).toList(),
      );
}

@freezed
abstract class VersesTafsir with _$VersesTafsir {
  const factory VersesTafsir({
    TypeVersesTafsir? id,
  }) = _VersesTafsir;

  const VersesTafsir._();

  VersesTafsirModel toModel() => VersesTafsirModel(
        id: id?.toModel(),
      );
}

@freezed
abstract class TypeVersesTafsir with _$TypeVersesTafsir {
  const factory TypeVersesTafsir({
    String? short,
    String? long,
  }) = _TypeVersesTafsir;

  const TypeVersesTafsir._();

  TypeVersesTafsirModel toModel() => TypeVersesTafsirModel(
        short: short,
        long: long,
      );
}
