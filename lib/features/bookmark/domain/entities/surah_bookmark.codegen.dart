import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../quran/domain/entities/language.codegen.dart';
import '../../../quran/domain/entities/surah_name.codegen.dart';

part 'surah_bookmark.codegen.freezed.dart';

@freezed
abstract class SurahBookmark with _$SurahBookmark {
  const factory SurahBookmark({
    required SurahName surahName,
    required int surahNumber,
    required Language revelation,
    required int totalVerses,
  }) = _SurahBookmark;
}
