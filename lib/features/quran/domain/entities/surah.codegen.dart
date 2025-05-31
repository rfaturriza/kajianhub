import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quranku/features/quran/domain/entities/language.codegen.dart';

import '../../data/models/surah_model.codegen.dart';
import 'surah_name.codegen.dart';

part 'surah.codegen.freezed.dart';

@freezed
abstract class Surah with _$Surah {
  const factory Surah({
    int? number,
    int? sequence,
    int? numberOfVerses,
    SurahName? name,
    Language? revelation,
    Language? tafsir,
  }) = _Surah;

  const Surah._();

  DataSurahModel toModel() => DataSurahModel(
        number: number,
        sequence: sequence,
        numberOfVerses: numberOfVerses,
        name: name?.toModel(),
        revelation: revelation?.toModel(),
        tafsir: tafsir?.toModel(),
      );
}
