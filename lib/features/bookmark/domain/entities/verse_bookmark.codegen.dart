import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quranku/features/quran/domain/entities/verses.codegen.dart';
import 'package:quranku/features/quran/domain/entities/juz.codegen.dart';

import '../../../quran/domain/entities/surah_name.codegen.dart';

part 'verse_bookmark.codegen.freezed.dart';

@freezed
abstract class VerseBookmark with _$VerseBookmark {
  const factory VerseBookmark({
    SurahName? surahName,
    int? surahNumber,
    JuzConstant? juz,
    required VersesNumber versesNumber,
  }) = _VerseBookmark;
}
