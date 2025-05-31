import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quranku/features/quran/data/models/surah_name_model.codegen.dart';

import 'language.codegen.dart';

part 'surah_name.codegen.freezed.dart';

@freezed
abstract class SurahName with _$SurahName {
  const factory SurahName({
    String? short,
    String? long,
    Language? transliteration,
    Language? translation,
  }) = _SurahName;

  const SurahName._();

  SurahNameModel toModel() => SurahNameModel(
        short: short,
        long: long,
        transliteration: transliteration?.toModel(),
        translation: translation?.toModel(),
      );
}
